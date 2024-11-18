{ config, secretsDir, ... }: {
  sops.secrets.tinyproxy-singbox = {
    sopsFile = secretsDir + /proxy.yaml;
    restartUnits = [ "container@tinyproxy.service" ];
    mode = "0600";
  };
  containers.tinyproxy = {
    # extraFlags = [ "-U" ];
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "10.10.10.6/24";
    bindMounts."/tmp/sing-box.json".hostPath = config.sops.secrets.tinyproxy-singbox.path;
    config = { pkgs, lib, ... }: {
      environment.systemPackages = [ pkgs.dnsutils pkgs.kitty ];
      systemd.packages = [ pkgs.sing-box ];
      systemd.services.sing-box = {
        preStart = ''
          umask 0077
          mkdir -p /etc/sing-box
          cp /tmp/sing-box.json /etc/sing-box/config.json
        '';
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "root";
          Group = "root";
        };
      };
      networking = {
        defaultGateway = "10.10.10.1";
        hostName = "tinyproxy-node";
        nameservers = [ "10.10.10.1" ];
        useHostResolvConf = false;
        firewall = {
          enable = true;
          allowedTCPPorts = [ 8888 8889 ];
          rejectPackets = false;
        };
      };
      system.stateVersion = "24.11";
    };
  };
}