{ modulesPath, inputs, lib, pkgs, config, options, ... }:
let
  zfs_arc_max = toString (1 * 1024 * 1024 * 1024);
in {
  imports = with inputs.self; [
    "${toString modulesPath}/profiles/hardened.nix"

    ./hardware-configuration.nix
    nixosRoles.hypervisor
    nixosProfiles.direnv
  ];

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

  # boot
  boot = {
    zfs.forceImportAll = lib.mkForce false;
    loader.efi.canTouchEfiVariables = false;
    loader.efi.efiSysMountPoint = "/boot/efi";
    loader.systemd-boot.enable = false;
    loader.generationsDir.copyKernels = true;
    loader.grub = {
      enable = true;
      device = "nodev";
      version = 2;
      efiSupport = true;
      enableCryptodisk = true;
      zfsSupport = true;
      efiInstallAsRemovable = true;
      copyKernels = true;
      # extraPrepareConfig = ''
      # '';
    };
    initrd = {
      supportedFilesystems = [ "zfs" ];
      luks.devices = {
        "cryptboot" = {
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
          bypassWorkqueues = config.deviceSpecific.isSSD;
          fallbackToPassword = true;
          # postOpenCommands = "";
          # preOpenCommands = "";
        };
        "cryptroot" = {
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
          bypassWorkqueues = config.deviceSpecific.isSSD;
          fallbackToPassword = true;
        };
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/keyfile0.bin";
      };
    };
    kernelPackages = pkgs.linuxPackages_hardened;
    kernelModules = [ "tcp_bbr" ];
    kernelParams = [
      "zfs.zfs_arc_max=${zfs_arc_max}"
      "zswap.enabled=0"
      "quiet"
      "scsi_mod.use_blk_mq=1"
      "modeset"
      "nofb"
      "pti=off"
      "spectre_v2=off"
      "kvm.ignore_msrs=1"
      "rd.systemd.show_status=auto"
      "rd.udev.log_priority=3"
    ];
    kernel.sysctl = {
      "kernel.sysrq" = false;
      "net.core.default_qdisc" = "sch_fq_codel";
      "net.ipv4.conf.all.accept_source_route" = false;
      "net.ipv4.icmp_ignore_bogus_error_responses" = true;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_rfc1337" = true;
      "net.ipv4.tcp_syncookies" = true;
      "net.ipv6.conf.all.accept_source_route" = false;
      # disable ipv6
      "net.ipv6.conf.all.disable_ipv6" = true;
      "net.ipv6.conf.default.disable_ipv6" = true;
    };
    kernel.sysctl = {
      "vm.swappiness" = 1;
    };
    cleanTmpDir = true;
  };

  # security.polkit.enable = true;
  # system.nssModules = lib.mkForce [ ];

  # services.nscd.enable = false;

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
    gpu = {
      vendor = "other";
    };
    bigScreen = false;
    ram = 12;
  };
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.wireguard.enable = false;
  deviceSpecific.isServer = true;

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "daily";

  # hardened
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];
  systemd.coredump.enable = false;
  programs.firejail.enable = true;
  # scudo memalloc is unstable
  # environment.memoryAllocator.provider = "libc";
  # environment.memoryAllocator.provider = "graphene-hardened";

  networking.wireless.enable = false;
  networking.networkmanager.enable = false;
  networking.hostName = config.device;

  services.timesyncd.enable = false;
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

  # virtualisation
  virtualisation.oci-containers.backend = lib.mkForce "podman";
  virtualisation.docker.enable = lib.mkForce false;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  fonts.enableDefaultFonts = lib.mkForce false;
  fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" "VictorMono" ]; }) ];

  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [ bat podman-compose ];
    xdg.mime.enable = false;
    home.stateVersion = "22.11";
  };
  system.stateVersion = "22.11";
}
