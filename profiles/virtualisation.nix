{ config, lib, pkgs, ... }:
with config.deviceSpecific; {
  # virtualisation.docker.enable = enableVirtualisation && (config.device == "AMD-Workstation");

  virtualisation.libvirtd = {
    enable = enableVirtualisation;
    qemu = {
      ovmf.enable = true;
      runAsRoot = true;
      package = pkgs.qemu;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  virtualisation.spiceUSBRedirection.enable = enableVirtualisation;

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
  };
}