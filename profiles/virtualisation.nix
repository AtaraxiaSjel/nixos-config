{ config, lib, pkgs, ... }:
with config.deviceSpecific; {
  config = lib.mkIf enableVirtualisation {
    virtualisation = {
      oci-containers.backend = lib.mkForce "podman";
      docker = {
        enable = true;
        daemon.settings = {
          features = { buildkit = true; };
        };
        storageDriver = "overlay2";
      };
      podman = {
        enable = true;
#         extraPackages = [ pkgs.zfs ];
#         dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
      containers.registries.search = [
        "docker.io" "gcr.io" "quay.io"
      ];
      containers.storage.settings = {
        storage = {
          driver = "overlay2";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
      lxd = lib.mkIf (!isContainer) {
        enable = true;
        zfsSupport = devInfo.fileSystem == "zfs";
        recommendedSysctlSettings = true;
      };
      lxc = {
        enable = true;
        lxcfs.enable = true;
        systemConfig = ''
          lxc.lxcpath = /var/lib/lxd/containers
          ${if devInfo.fileSystem == "zfs" then ''
            lxc.bdev.zfs.root = rpool/persistent/lxd
          '' else ""}
        '';
#         defaultConfig = ''
#           lxc.idmap = u 0 100000 65535
#           lxc.idmap = g 0 100000 65535
#           lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf
#         '';
      };
      libvirtd = {
        enable = true;
        qemu = {
          ovmf.enable = true;
          ovmf.packages = [
            pkgs.OVMFFull.fd
            pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd
          ];
          runAsRoot = false;
        };
        onBoot = "ignore";
        onShutdown = "shutdown";
      };

      spiceUSBRedirection.enable = true;
    };

    security.unprivilegedUsernsClone = true;

    home-manager.users.${config.mainuser} = {
      home.file.".config/containers/storage.conf".text = ''
        [storage]
        driver = "overlay2"
      '';
      home.file.".config/libvirt/libvirt.conf".text = ''
        uri_default = "qemu:///system"
      '';
    };

#     users.users.${config.mainuser} = {
#       subUidRanges = [{
#         count = 1000;
#         startUid = 10000;
#       }];
#       subGidRanges = [{
#         count = 1000;
#         startGid = 10000;
#       }];
#     };

    programs.extra-container.enable = true;

    persist.state.directories = lib.mkIf (devInfo.fileSystem != "zfs") [
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/var/lib/containers"
      "/var/lib/lxd"
    ];
  };
}
