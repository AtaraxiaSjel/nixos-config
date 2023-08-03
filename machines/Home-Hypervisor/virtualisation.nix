{ config, pkgs, lib, ... }: {
  boot.kernelModules = [ "x_tables" ];

  environment.systemPackages = [ pkgs.virtiofsd ];

  virtualisation = {
    oci-containers.backend = lib.mkForce "podman";
    docker.enable = lib.mkForce false;
    podman = {
      enable = true;
      extraPackages = [ pkgs.zfs ];
      dockerSocket.enable = true;
      # defaultNetwork.settings.dns_enabled = true;
    };
    containers.registries.search = [
      "docker.io" "gcr.io" "quay.io"
    ];
    containers.storage.settings = {
      storage = {
        driver = "overlay";
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
    };
    libvirtd = {
      enable = true;
      qemu = {
        ovmf.enable = true;
        ovmf.packages = [
          pkgs.OVMFFull.fd
          # pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd
        ];
        runAsRoot = false;
      };
      onBoot = "ignore";
      onShutdown = "shutdown";
    };
  };

  security.unprivilegedUsernsClone = true;

  home-manager.users.${config.mainuser} = {
    home.file.".config/containers/storage.conf".text = ''
      [storage]
      driver = "overlay"
    '';
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