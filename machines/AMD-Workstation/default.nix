{ inputs, config, lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.workstation

    inputs.self.nixosProfiles.stable-diffusion
    # inputs.self.nixosModules.passthrough
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "amd";
      clock = 3700;
      cores = 6;
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
  deviceSpecific.wireguard.enable = true;

  boot.zfs.forceImportAll = lib.mkForce false;

  hardware.video.hidpi.enable = lib.mkForce false;
  hardware.firmware = [ pkgs.rtl8761b-firmware ];

  home-manager.users.alukard.home.packages = lib.mkIf config.deviceSpecific.enableVirtualisation [
    inputs.nixos-generators.packages.${pkgs.system}.nixos-generate

    # pkgs.looking-glass-client
  ];

  # VFIO Passthough
  # virtualisation = {
    # sharedMemoryFiles = {
      # # scream = {
      # #   user = "alukard";
      # #   group = "qemu-libvirtd";
      # #   mode = "666";
      # # };
      # looking-glass = {
        # user = "alukard";
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
