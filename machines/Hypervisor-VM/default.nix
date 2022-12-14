{ modulesPath, inputs, lib, pkgs, config, options, ... }: {
  imports = with inputs.self; [
    "${toString modulesPath}/profiles/hardened.nix"

    ./hardware-configuration.nix
    ./boot.nix
    # ./persistent.nix
    nixosRoles.hypervisor
    nixosProfiles.direnv
    nixosModules.persist
  ];

  fileSystems = {
    "/home/alukard/conf" = {
      fsType = "virtiofs";
      device = "viofs";
      options = [
        "defaults"
        "nofail"
      ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 80;
    numDevices = 1;
  };

  # Impermanence
  persist = {
    enable = true;
    cache.clean.enable = true;
    state.files = [ "/etc/machine-id" ];
  };
  fileSystems."/home".neededForBoot = true;
  fileSystems."/persistent".neededForBoot = true;
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/nixos/root@empty
    zfs rollback -r rpool/user/home@empty
  '';

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

  # security.polkit.enable = true;

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
    fileSystem = "zfs";
  };
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.wireguard.enable = false;
  deviceSpecific.isServer = true;

  services.zfs = {
    autoScrub.enable = true;
    autoScrub.interval = "daily";
    trim.enable = true;
    trim.interval = "weekly";
  };

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
