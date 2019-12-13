{ pkgs, config, lib, ... }:
with rec {
  inherit (config) device devices deviceSpecific;
};
with deviceSpecific; {

  hardware.cpu.${devices.${device}.cpu.vendor}.updateMicrocode = true; # Update microcode
  hardware.enableRedistributableFirmware = true; # For some unfree drivers

  # Enable hardware video acceleration for Intel
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  boot.initrd.kernelModules = if video == "intel" then [ "iHD" ] else [ ];
  hardware.opengl =  {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = if video == "intel" then [
      pkgs.vaapiIntel
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
      pkgs.intel-media-driver
    ] else [ ];
  };
  environment.sessionVariables = {
    GST_VAAPI_ALL_DRIVERS = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };
  # --- END ---

  hardware.bluetooth.enable = isLaptop;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = if isVM then
    pkgs.linuxPackages
  else
    pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.blacklistedKernelModules = lib.mkIf (device == "Dell-Laptop") [
    "psmouse"
  ];
  boot.kernelParams = lib.mkIf (device == "Dell-Laptop") [
    "mem_sleep_default=deep"
  ];

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # package = pkgs.pulseaudioFull;
    support32Bit = true;
    # systemWide = true;
    tcp = {
      enable = true;
      anonymousClients.allowedIpRanges = ["127.0.0.1"];
    };
  };
  boot.extraModprobeConfig = lib.mkIf (device == "AMD-Workstation") ''
    options snd slots=snd_virtuoso,snd_usb_audio
  '';

  # SSD Section
  boot.kernel.sysctl = {
    "vm.swappiness" = if isSSD then 1 else 10;
  };
  services.fstrim = {
    enable = isSSD;
    interval = "weekly";
  };

  services.fwupd.enable = (device == "Dell-Laptop");

  services.udev.packages = [ pkgs.stlink ];

}
