{ config, lib, pkgs, ... }:
with config.deviceSpecific; {
  config = lib.mkIf enableVirtualisation {
    # virtualisation.podman = {
    #   enable = isServer;
    #   dockerCompat = true;
    #   defaultNetwork.dnsname.enable = true;
    # };
    virtualisation.docker = {
      enable = isServer;
    };

    # virtualisation.oci-containers.backend = "docker";
    # virtualisation.oci-containers.backend = lib.mkForce "podman";

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

    environment.systemPackages = if isServer then [
      # arion
      # docker-client
    ] else [
      virt-manager
    ];
  };
}