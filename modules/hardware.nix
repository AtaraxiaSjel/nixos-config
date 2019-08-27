{ pkgs, config, lib, ... }:
with rec {
  inherit (config) device devices deviceSpecific;
};
with deviceSpecific; {

  hardware.cpu.${devices.${device}.cpu.vendor}.updateMicrocode = true; # Update microcode
  # hardware.enableRedistributableFirmware = true; # For some unfree drivers

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true; # For steam

  hardware.bluetooth.enable = isLaptop;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = if config.virtualisation.virtualbox.guest.enable == false then
      pkgs.linuxPackages_latest
    else
      pkgs.linuxPackages;
    supportedFilesystems = [ "ntfs" ];
    extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
  };

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # package = pkgs.pulseaudioFull;
    support32Bit = true;
    # systemWide = true;
  };
}
