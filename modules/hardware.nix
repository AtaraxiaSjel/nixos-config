{ pkgs, config, lib, ... }:
with rec {
  inherit (config) device devices deviceSpecific;
};
with deviceSpecific; {

  hardware.cpu.${devices.${device}.cpu.vendor}.updateMicrocode = true; # Update microcode
  hardware.enableRedistributableFirmware = true; # For some unfree drivers

  # Enable hardware video acceleration
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
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

  hardware.bluetooth.enable = isLaptop;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = if isVM then
      pkgs.linuxPackages
    else
      pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" ];
    # extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
  };

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # package = pkgs.pulseaudioFull;
    support32Bit = true;
    # systemWide = true;
  };

  # SSD Section
  boot.kernel.sysctl = {
    "vm.swappiness" = if isSSD then 1 else 10;
  };
  services.fstrim = {
    enable = isSSD;
    interval = "weekly";
  };

}
