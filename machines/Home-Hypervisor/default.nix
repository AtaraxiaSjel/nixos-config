{ inputs, lib, pkgs, config, ... }:
{
  imports = with inputs.self; [
    inputs.disko.nixosModules.disko
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-terminfo

    ./disk-config.nix

    ./backups.nix
    ./boot.nix
    ./networking.nix
    ./virtualisation.nix
    customProfiles.hardened
    customRoles.hypervisor

    ./nginx.nix

    # customProfiles.tg-bot

    customProfiles.acme
    # customProfiles.attic
    # customProfiles.atticd
    # customProfiles.authentik
    # customProfiles.battery-historian
    customProfiles.coturn
    # customProfiles.fail2ban
    customProfiles.gitea
    # customProfiles.homepage
    # customProfiles.hoyolab
    customProfiles.inpx-web
    customProfiles.it-tools
    customProfiles.media-stack
    # customProfiles.metrics
    # customProfiles.minio
    # customProfiles.netbird-server
    # customProfiles.nginx
    # customProfiles.ocis
    # customProfiles.onlyoffice
    # customProfiles.openbooks
    # customProfiles.outline
    customProfiles.radicale
    # customProfiles.spdf
    customProfiles.synapse
    customProfiles.tinyproxy
    # customProfiles.vault
    customProfiles.vaultwarden
    customProfiles.webhooks
    customProfiles.wiki
    # customProfiles.yandex-db

    # (import customProfiles.blocky {
    #   inherit (import ./dns-mapping.nix) dnsmasq-list;
    # })

    # (import customProfiles.headscale {
    #   inherit (import ./dns-mapping.nix) headscale-list;
    # })
  ];
  security.lockKernelModules = lib.mkForce false;

  deviceSpecific.devInfo = {
    cpu.vendor = "intel";
    drive.type = "ssd";
    gpu.vendor = "other";
    ram = 8;
    fileSystem = "zfs";
  };
  deviceSpecific.isServer = true;
  deviceSpecific.vpn.tailscale.enable = true;
  # Tailscale auto-login
  # services.headscale-auth.home-hypervisor = {
  #   outPath = "/tmp/hypervisor-authkey";
  #   before = [ "tailscaled-autoconnect.service" ];
  # };
  # services.tailscale = {
  #   authKeyFile = "/tmp/hypervisor-authkey";
  #   extraUpFlags = [
  #     "--login-server=https://wg.ataraxiadev.com"
  #     "--accept-dns=false"
  #     "--advertise-exit-node=false"
  #     "--operator=${config.mainuser}"
  #   ];
  # };

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

  fileSystems."/media/local-nfs" = {
    device = "10.10.10.11:/";
    fsType = "nfs4";
    options = [ "nfsvers=4.2" "x-systemd.automount" "noauto" ];
  };

  environment.memoryAllocator.provider = "libc";
  services.udisks2.enable = false;
  fonts.enableDefaultPackages = false;
  fonts.packages = with pkgs; [ nerd-fonts.fira-code nerd-fonts.victor-mono ];

  security.polkit.enable = true;

  services.zfs = {
    autoScrub.enable = true;
    autoScrub.interval = "monthly";
    trim.enable = true;
    trim.interval = "weekly";
  };
  services.postgresql.enable = true;
  services.postgresql.settings = {
    full_page_writes = "off";
    wal_init_zero = "off";
    wal_recycle = "off";
  };

  nix.settings.experimental-features = [
    "cgroups"
    "fetch-closure"
    "recursive-nix"
  ];

  environment.systemPackages = with pkgs; [ nfs-utils ];
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
      mkvtoolnix-cli
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
    home.stateVersion = "24.11";
  };
  system.stateVersion = "24.11";
}
