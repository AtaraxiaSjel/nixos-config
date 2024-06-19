{ inputs, lib, pkgs, config, ... }:
let persistRoot = config.autoinstall.persist.persistRoot or "/persist";
in {
  imports = with inputs.self; [
    ./backups.nix
    ./boot.nix
    ./hardware-configuration.nix
    ./usb-hdd.nix
    ./virtualisation.nix
    customProfiles.hardened
    customRoles.hypervisor

    customProfiles.acme
    customProfiles.attic
    customProfiles.atticd
    customProfiles.authentik
    customProfiles.battery-historian
    customProfiles.fail2ban
    customProfiles.gitea
    customProfiles.homepage
    customProfiles.hoyolab
    customProfiles.inpx-web
    customProfiles.it-tools
    customProfiles.media-stack
    customProfiles.metrics
    customProfiles.minio
    customProfiles.nginx
    customProfiles.ocis
    customProfiles.onlyoffice
    customProfiles.openbooks
    customProfiles.outline
    customProfiles.radicale
    customProfiles.spdf
    customProfiles.synapse
    customProfiles.tinyproxy
    customProfiles.vault
    customProfiles.vaultwarden
    customProfiles.vscode-server
    customProfiles.webhooks
    customProfiles.wiki
    customProfiles.yandex-db

    (import customProfiles.blocky {
      inherit (import ./dns-mapping.nix) dnsmasq-list;
    })

    (import customProfiles.headscale {
      inherit (import ./dns-mapping.nix) headscale-list;
    })
  ];
  security.lockKernelModules = lib.mkForce false;

  deviceSpecific.devInfo = {
    cpu.vendor = "intel";
    drive.type = "ssd";
    gpu.vendor = "other";
    ram = 12;
    fileSystem = "zfs";
  };
  deviceSpecific.isServer = true;
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.vpn.tailscale.enable = true;
  # Tailscale auto-login
  services.headscale-auth.home-hypervisor = {
    outPath = "/tmp/hypervisor-authkey";
    before = [ "tailscaled-autoconnect.service" ];
  };
  services.tailscale = {
    authKeyFile = "/tmp/hypervisor-authkey";
    extraUpFlags = [
      "--login-server=https://wg.ataraxiadev.com"
      "--accept-dns=false"
      "--advertise-exit-node=false"
      "--operator=${config.mainuser}"
    ];
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 150;
  };

  # Impermanence
  persist = {
    enable = true;
    cache.clean.enable = true;
    state = {
      files = [ "/etc/machine-id" ];
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
    127.0.0.1 auth.ataraxiadev.com
    127.0.0.1 code.ataraxiadev.com
    127.0.0.1 cache.ataraxiadev.com
    127.0.0.1 s3.ataraxiadev.com
    127.0.0.1 wg.ataraxiadev.com
    127.0.0.1 vault.ataraxiadev.com
    127.0.0.1 matrix.ataraxiadev.com
  '';

  nix.optimise.automatic = false;

  services.logind.lidSwitch = "lock";
  services.logind.lidSwitchDocked = "lock";
  services.logind.lidSwitchExternalPower = "lock";
  systemd.services.systemd-timesyncd.wantedBy = [ "multi-user.target" ];
  systemd.timers.systemd-timesyncd = { timerConfig.OnCalendar = "hourly"; };

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
      lnav
      micro
      nix-index-update
      p7zip
      podman-compose
      pwgen
      rclone
      repgrep
      restic
      rsync
      rustic-rs
      smartmontools
    ];
    xdg.mime.enable = false;
    home.stateVersion = "24.05";
  };
  system.stateVersion = "24.05";
}
