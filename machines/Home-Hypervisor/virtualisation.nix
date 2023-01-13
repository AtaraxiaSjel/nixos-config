{ config, pkgs, lib, ... }: {
  boot.kernelModules = [
    "xt_nat"
    # "iptable_nat"
    # "iptable_filter"
  ];

  virtualisation = {
    oci-containers.backend = lib.mkForce "podman";
    docker.enable = lib.mkForce false;
    podman = {
      enable = true;
      extraPackages = [ pkgs.zfs ];
      # defaultNetwork.settings.dns_enabled = true;
    };
    containers.registries.search = [
      "docker.io" "gcr.io" "quay.io"
    ];
    containers.storage.settings = {
      storage = {
        driver = "zfs";
        graphroot = "/var/lib/podman/storage";
        runroot = "/run/containers/storage";
      };
    };
    lxd = {
      enable = true;
      zfsSupport = true;
      recommendedSysctlSettings = true;
    };
    lxc = {
      enable = true;
      lxcfs.enable = true;
      systemConfig = ''
        lxc.lxcpath = /var/lib/lxd/containers
        lxc.bdev.zfs.root = rpool/persistent/lxd
      '';
      # defaultConfig = ''
      #   lxc.idmap = u 0 100000 65535
      #   lxc.idmap = g 0 100000 65535
      #   lxc.include = ${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf
      # '';
    };
    libvirtd = {
      enable = true;
      qemu = {
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        runAsRoot = false;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
  };

  security.unprivilegedUsernsClone = true;

  # users.users.podmanmanager = {
  #   uid = 1100;
  #   isSystemUser = true;
  #   description = "User that runs podman containers";
  #   autoSubUidGidRange = true;
  #   createHome = true;
  #   extraGroups = [ "podman" ];
  #   hashedPassword = "!";
  #   home = "/home/podmanmanager";
  #   group = "podmanmanager";
  # };
  # users.groups.podmanmanager = {};

  home-manager.users.${config.mainuser} = {
    home.file.".config/containers/storage.conf".text = ''
      [storage]
      driver = "overlay"
    '';
    # [storage.options.overlay]
    # mount_program = "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs"
  };

  users.users.${config.mainuser} = {
    subUidRanges = [{
      count = 1000;
      startUid = 10000;
    }];
    subGidRanges = [{
      count = 1000;
      startGid = 10000;
    }];
  };
}