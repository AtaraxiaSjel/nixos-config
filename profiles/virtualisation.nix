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
        defaultNetwork.settings.dns_enabled = true;
        dockerSocket.enable = !config.virtualisation.docker.enable;
      };
      containers.registries.search = [
        "docker.io" "ghcr.io" "quay.io"
      ];
      containers.storage.settings = {
        storage = {
          driver = "overlay";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
      libvirtd = {
        enable = true;
        qemu = {
          ovmf.enable = true;
          ovmf.packages = [
            (pkgs.OVMFFull.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
          runAsRoot = false;
          swtpm.enable = true;
        };
        onBoot = "ignore";
        onShutdown = "shutdown";
      };

      spiceUSBRedirection.enable = !isServer;
    };

    environment.systemPackages = [ pkgs.virtiofsd ];

    users.users."qemu-libvirtd" = {
      extraGroups =
        lib.optionals (!config.virtualisation.libvirtd.qemu.runAsRoot)
        [ "kvm" "input" ];
    };

    security.unprivilegedUsernsClone = true;

    home-manager.users.${config.mainuser} = {
      home.file.".config/containers/storage.conf".text = ''
        [storage]
        driver = "overlay"
      '';
      home.file.".config/libvirt/libvirt.conf".text = ''
        uri_default = "qemu:///system"
      '';
    };

    programs.extra-container.enable = !isServer;
    programs.virt-manager.enable = !isServer;

    persist.state.homeDirectories = [
      ".config/containers"
    ];

    persist.state.directories = lib.mkIf (devInfo.fileSystem != "zfs") [
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/var/lib/containers"
    ];
  };
}
