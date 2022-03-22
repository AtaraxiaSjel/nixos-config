{ config, lib, pkgs, ... }:
with config.deviceSpecific; {
  config = lib.mkIf enableVirtualisation {
    virtualisation.docker = {
      enable = isServer;
    };
    virtualisation.oci-containers.backend = "docker";

    virtualisation.libvirtd = {
      enable = !isServer;
      qemu = {
        ovmf.enable = true;
        runAsRoot = true;
        package = pkgs.qemu;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    virtualisation.spiceUSBRedirection.enable = true;

    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
    };

    environment.systemPackages = with pkgs; if isServer then [
    ] else [
      virt-manager
    ];
  };
}