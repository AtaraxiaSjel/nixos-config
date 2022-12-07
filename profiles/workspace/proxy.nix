{ config, pkgs, lib, ... }: {
  disabledModules = [ "services/networking/xray.nix" ];

  secrets.xray-config = {};
  secrets.tor-config = {};

  services.xray = {
    enable = true;
    settingsFile = config.secrets.xray-config.decrypted;
  };

  containers.tor = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.1.10";
    localAddress = "192.168.1.11";
    bindMounts."/var/secrets" = {
      hostPath = "/var/secrets";
      isReadOnly = true;
    };
    tmpfs = [ "/" ];
    ephemeral = true;
    config = { config, pkgs, ... }: {
      services.tor.enable = true;

      systemd.services.tor-config = {
        script = ''
          cp /var/secrets/tor-config /var/lib/tor/tor-config
          chown tor /var/lib/tor/tor-config
          chmod 600 /var/lib/tor/tor-config
          sed -i 's#obfs4proxy-path#${pkgs.obfs4}/bin/obfs4proxy#' /var/lib/tor/tor-config
        '';
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
      };

      systemd.services.tor = {
        after = [ "tor-config.service" ];
        serviceConfig.ExecStart = lib.mkForce "${config.services.tor.package}/bin/tor -f /var/lib/tor/tor-config";
      };

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 9050 ];
        rejectPackets = true;
      };
      # environment.etc."resolv.conf".text = "nameserver 192.168.0.1";
      system.stateVersion = "22.11";
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-tor" ];
    externalInterface = "wg-mullvad";
  };
}