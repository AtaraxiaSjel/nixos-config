{ inputs, config, lib, pkgs, ... }: {
  imports = with inputs.self; [
    ./boot.nix
    ./hardware-configuration.nix
    nixosRoles.workstation

    # nixosProfiles.stable-diffusion
    nixosProfiles.a2ln-server
    # nixosProfiles.sunshine

    # customModules.passthrough
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "amd";
      clock = 3700;
      cores = 12;
    };
    drive = {
      type = "ssd";
      speed = 6000;
      size = 1000;
    };
    gpu = {
      vendor = "amd";
    };
    bigScreen = true;
    ram = 48;
    fileSystem = "zfs";
  };
  deviceSpecific.isHost = true;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = true;
  deviceSpecific.enableVirtualisation = true;
  deviceSpecific.vpn.mullvad.enable = true;

  hardware.video.hidpi.enable = lib.mkForce false;
  hardware.firmware = [ pkgs.rtl8761b-firmware ];

  networking.firewall.allowedTCPPorts = [ 52736 ];

  secrets.files-veracrypt = {};
  environment.etc.crypttab = {
    text = ''
      files-veracrypt /dev/disk/by-partuuid/15fa11a1-a6d8-4962-9c03-74b209d7c46a /var/secrets/files-veracrypt tcrypt-veracrypt
    '';
  };

  fileSystems = {
    # "/media/sys" = {
    #   fsType = "ntfs";
    #   device = "/dev/disk/by-partuuid/7d14b1b8-288a-4a5c-a306-6e6ba714d089";
    #   options = [
    #     "nofail"
    #     "uid=${toString config.users.users.${config.mainuser}.uid}"
    #     "gid=${toString config.users.groups.users.gid}"
    #   ];
    # };
    "/media/files" = {
      fsType = "ntfs";
      device = "/dev/mapper/files-veracrypt";
      options = [
        "nofail"
        "uid=${toString config.users.users.${config.mainuser}.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  services.openssh.settings.PermitRootLogin = lib.mkForce "without-password";

  services.ratbagd.enable = true;

  home-manager.users.${config.mainuser} = {
    home.packages = lib.mkIf config.deviceSpecific.enableVirtualisation [
      inputs.nixos-generators.packages.${pkgs.hostPlatform.system}.nixos-generate
      # inputs.prismlauncher.packages.${pkgs.hostPlatform.system}.default
      # pkgs.looking-glass-client
      pkgs.prismlauncher
      pkgs.piper
      pkgs.osu-lazer-bin
      pkgs.nixpkgs-review
      pkgs.anydesk
      pkgs.winbox
    ];
    home.stateVersion = "22.11";
  };

  system.stateVersion = "22.11";

  # VFIO Passthough
  # virtualisation = {
    # sharedMemoryFiles = {
      # # scream = {
      # #   user = config.mainuser;
      # #   group = "qemu-libvirtd";
      # #   mode = "666";
      # # };
      # looking-glass = {
        # user = config.mainuser;
        # group = "libvirtd";
        # mode = "666";
      # };
    # };
    # libvirtd = {
      # enable = true;
      # qemu = {
        # ovmf.enable = true;
        # runAsRoot = lib.mkForce true;
      # };
#
      # onBoot = "ignore";
      # onShutdown = "shutdown";
#
      # clearEmulationCapabilities = false;
#
      # deviceACL = [
        # # "/dev/input/by-path/pci-0000:0b:00.3-usb-0:2.2.4:1.0-event-mouse" # Trackball
        # # "/dev/input/by-path/pci-0000:0b:00.3-usb-0:2.2.3:1.0-event-kbd" # Tastatur
        # # "/dev/input/by-path/pci-0000:0b:00.3-usb-0:2.2.3:1.1-event-mouse" # Tastatur
        # # "/dev/input/by-path/pci-0000:0b:00.3-usb-0:2.2.3:1.1-mouse" # Tastatur
        # "/dev/vfio/vfio"
        # "/dev/vfio/17"
        # "/dev/kvm"
        # # "/dev/shm/scream"
        # "/dev/shm/looking-glass"
      # ];
    # };
    # vfio = {
      # enable = true;
      # IOMMUType = "amd";
      # # group 17: 0b:00.0 and 0b:00.1
      # devices = [ "10de:1244" "10de:0bee" ];
      # blacklistNvidia = true;
      # disableEFIfb = false;
      # ignoreMSRs = true;
      # applyACSpatch = false;
    # };
    # hugepages = {
      # enable = true;
      # defaultPageSize = "1G";
      # pageSize = "1G";
      # numPages = 6;
    # };
  # };
}
