{ modulesPath, inputs, lib, pkgs, config, options, ... }:
let persistRoot = config.autoinstall.persist.persistRoot or "/persist";
in {
  imports = with inputs.self; [
    ./boot.nix
    ./hardware-configuration.nix
    ./virtualisation.nix
    ./disks.nix
    ./backups.nix
    customProfiles.hardened

    customRoles.hypervisor
    customProfiles.acme
    customProfiles.authentik
    customProfiles.battery-historian
    customProfiles.fail2ban
    # customProfiles.firefox-syncserver
    customProfiles.gitea
    customProfiles.joplin-server
    # customProfiles.mailserver
    customProfiles.nginx
    # customProfiles.roundcube
    customProfiles.tinyproxy
    customProfiles.vaultwarden
    customProfiles.vscode-server

    customProfiles.media-stack
    # customProfiles.copyparty
    customProfiles.seafile
    customProfiles.spdf
    # customProfiles.cocalc
    # customProfiles.neko-browser
    customProfiles.openbooks
    customProfiles.webhooks

    customProfiles.yandex-db
    customProfiles.hoyolab
    customProfiles.it-tools
    customProfiles.homepage
    customProfiles.matrix
    customProfiles.atticd
    customProfiles.attic
    # customProfiles.restic-server
    customProfiles.outline
    customProfiles.radicale
    customProfiles.wiki

    (import customProfiles.blocky {
      inherit config;
      inherit (import ./dns-mapping.nix) dns-mapping;
    })

    (import customProfiles.headscale {
      inherit config pkgs;
      inherit (import ./dns-headscale.nix) dns-mapping;
    })
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "intel";
      clock = 2300;
      cores = 4;
    };
    drive = {
      type = "ssd";
      speed = 500;
      size = 500;
    };
    gpu = { vendor = "other"; };
    bigScreen = false;
    ram = 12;
    fileSystem = "zfs";
  };
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.vpn.mullvad.enable = false;
  deviceSpecific.isServer = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 150;
  };

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "client";
  # Impermanence
  persist = {
    enable = true;
    cache.clean.enable = true;
    state = {
      files = [ "/etc/machine-id" ];
      directories = [ "/var/lib/tailscale" ];
    };
  };
  fileSystems."/home".neededForBoot = true;
  fileSystems.${persistRoot}.neededForBoot = true;
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/nixos/root@empty
    zfs rollback -r rpool/user/home@empty
  '';

  environment.memoryAllocator.provider = "libc";

  # build hell
  environment.noXlibs = lib.mkForce false;
  # minimal profile
  documentation.nixos.enable = lib.mkForce false;
  programs.command-not-found.enable = lib.mkForce false;
  xdg.autostart.enable = lib.mkForce false;
  xdg.icons.enable = lib.mkForce false;
  xdg.mime.enable = lib.mkForce false;
  xdg.sounds.enable = lib.mkForce false;
  services.udisks2.enable = lib.mkForce false;

  fonts.enableDefaultPackages = lib.mkForce false;
  fonts.packages =
    [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" "VictorMono" ]; }) ];

  security.polkit.enable = true;
  # security.pam.enableSSHAgentAuth = true;

  services.zfs = {
    autoScrub.enable = true;
    autoScrub.interval = "monthly";
    trim.enable = true;
    trim.interval = "weekly";
  };

  # hardened
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = lib.mkDefault [ ];
  networking.firewall.allowedUDPPorts = lib.mkDefault [ ];
  systemd.coredump.enable = false;
  programs.firejail.enable = true;

  networking.wireless.enable = false;
  networking.networkmanager.enable = false;
  networking.hostName = config.device;

  networking.nameservers = [ "192.168.0.1" ];
  networking.defaultGateway = "192.168.0.1";
  networking.bridges.br0.interfaces = [ "enp2s0f0" ];
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.0.10";
      prefixLength = 24;
    }];
  };
  networking.extraHosts = ''
    127.0.0.1 code.ataraxiadev.com
    127.0.0.1 cache.ataraxiadev.com
  '';

  # networking.proxy.default = "http://127.0.0.1:3128";

  nix.optimise.automatic = false;

  services.logind.lidSwitch = "lock";
  services.logind.lidSwitchDocked = "lock";
  services.logind.lidSwitchExternalPower = "lock";
  services.timesyncd.enable = lib.mkForce false;
  services.openntpd.enable = true;
  networking.timeServers = [
    "0.ru.pool.ntp.org"
    "1.ru.pool.ntp.org"
    "2.ru.pool.ntp.org"
    "3.ru.pool.ntp.org"
    "0.europe.pool.ntp.org"
    "1.europe.pool.ntp.org"
    "2.europe.pool.ntp.org"
    "3.europe.pool.ntp.org"
  ] ++ options.networking.timeServers.default;

  home-manager.users.${config.mainuser} = {
    home.file.".config/libvirt/libvirt.conf".text = ''
      uri_default = "qemu:///system"
    '';
    home.packages = with pkgs; [
      bat
      bottom
      comma
      dig.dnsutils
      fd
      kitty
      micro
      nix-index-update
      p7zip
      podman-compose
      pwgen
      rclone
      repgrep
      restic
      rustic-rs
      smartmontools
    ];
    xdg.mime.enable = false;
    home.stateVersion = "22.11";
  };
  system.stateVersion = "22.11";
}
