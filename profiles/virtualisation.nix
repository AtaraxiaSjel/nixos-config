{ config, lib, pkgs, ... }:
with config.deviceSpecific; {
  # virtualisation.docker.enable = enableVirtualisation && (config.device == "AMD-Workstation");

  virtualisation.libvirtd = {
    enable = enableVirtualisation;
    qemuOvmf = true;
    qemuRunAsRoot = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemuPackage = pkgs.qemu;
  };

  virtualisation.spiceUSBRedirection.enable = enableVirtualisation;

  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
  };
}