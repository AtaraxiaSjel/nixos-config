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
      enable = true;
      qemu = {
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        runAsRoot = false;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    home-manager.users.alukard = {
      home.file.".config/libvirt/libvirt.conf".text = ''
        uri_default = "qemu:///system"
      '';
      home.packages = with pkgs; [
        docker-compose
        virt-manager
      ];
    };

    virtualisation.lxd = lib.mkIf (!isContainer) {
      enable = true;
      zfsSupport = (devInfo.fileSystem == "zfs");
      recommendedSysctlSettings = true;
    };
    virtualisation.lxc = lib.mkIf (!isContainer) {
      enable = true;
      lxcfs.enable = true;
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
      # externalInterface = "enp8s0";
    };
  };
}