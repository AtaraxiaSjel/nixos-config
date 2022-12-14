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

    ephemeral = true;
    # extraFlags = [ "-U" ]; # unprivileged
    hostAddress = "192.168.1.10";
    localAddress = "192.168.1.11";
    privateNetwork = true;
    tmpfs = [ "/" ];
    bindMounts."/var/secrets" = {
      hostPath = "/var/secrets";
      isReadOnly = true;
    };
    config = { config, pkgs, ... }: {
      # users.mutableUsers = false;
      # users.users.${config.mainuser} = {
      #   isNormalUser = true;
      #   extraGroups = [ "wheel" ];
      #   hashedPassword = "$6$kDBGyd99tto$9LjQwixa7NYB9Kaey002MD94zHob1MmNbVz9kx3yX6Q4AmVgsFMGUyNuHozXprxyuXHIbOlTcf8nd4rK8MWfI/";
      # };

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
        rejectPackets = false;
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