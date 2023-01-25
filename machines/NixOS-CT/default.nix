{ inputs, lib, config, ... }: {
  imports = with inputs.self.customModules; with inputs.self.nixosProfiles; [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.container

    direnv
    virtualisation

    fail2ban
    gitea
    joplin-server
    mailserver
    microbin
    nginx
    roundcube
    # seafile
    vaultwarden

    battery-historian
    # media-stack
    duplicacy
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "intel";
      clock = 2300;
      cores = 2;
    };
    drive = {
      type = "hdd";
      speed = 100;
      size = 10;
    };
    gpu = {
      vendor = "other";
    };
    bigScreen = false;
    ram = 1;
  };
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.wireguard.enable = false;
  deviceSpecific.isServer = lib.mkForce true;

  systemd.suppressedSystemUnits = [
    "sys-kernel-debug.mount"
  ];

  environment.noXlibs = lib.mkForce false;

  networking = {
    enableIPv6 = false;
    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" ];
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.0.12";
      prefixLength = 24;
    }];
  };

  home-manager.users.${config.mainuser}.home.stateVersion = "21.11";
  system.stateVersion = "21.11";
}
