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

      nixpkgs.overlays = [(final: prev: {
        sing-box =
        if (lib.versionOlder prev.sing-box.version "1.10.1") then
          prev.sing-box.overrideAttrs (_: {
            version = "1.10.1";
            src = prev.fetchFromGitHub {
              owner = "SagerNet";
              repo = "sing-box";
              rev = "v1.10.1";
              hash = "sha256-WGlYaD4u9M1hfT+L6Adc5gClIYOkFsn4c9FAympmscQ=";
            };
            vendorHash = "sha256-lyZ2Up1SSaRGvai0gGtq43MSdHfXc2PuxflSbASYZ4A=";
          })
        else
          prev.sing-box;
      })];

      system.stateVersion = "24.11";
    };
  };
}