{ config, lib, pkgs, ... }:
with config.deviceSpecific; {
  config = lib.mkIf enableVirtualisation {
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        features = { buildkit = true; };
      };
      storageDriver = if (devInfo.fileSystem == "zfs") then
        "zfs"
      else if (devInfo.fileSystem == "btrfs") then
        "btrfs"
      else
        "overlay2";
    };
    virtualisation.oci-containers.backend = "docker";

    virtualisation.libvirtd = {
      enable = !isServer;
      qemu = {
        # ovmf.enable = true;
        runAsRoot = true;
        # package = pkgs.qemu;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    virtualisation.lxd = {
      enable = !isContainer;
      zfsSupport = (devInfo.fileSystem == "zfs");
      recommendedSysctlSettings = true;
    };
    virtualisation.lxc = {
      enable = !isContainer;
      lxcfs.enable = !isContainer;
      systemConfig = ''
        lxc.lxcpath = /var/lib/lxd/containers
        ${if devInfo.fileSystem == "zfs" then ''
          lxc.bdev.zfs.root = rpool/lxd
        '' else ""}
      '';
      defaultConfig = ''
        lxc.idmap = u 0 100000 65535
        lxc.idmap = g 0 100000 65535
        lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf
      '';
    };

    virtualisation.spiceUSBRedirection.enable = true;

    networking.nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
    };

    environment.systemPackages = with pkgs; if isServer then [
    ] else [
      docker-compose
      virt-manager
    ];
  };
}