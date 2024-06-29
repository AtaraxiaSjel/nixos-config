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
        dockerSocket.enable = true;
      };
      containers.registries.search = [
        "docker.io" "gcr.io" "quay.io"
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

    networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 5353 ];

    # cross compilation of aarch64 uefi currently broken
    # link existing extracted from fedora package
    system.activationScripts.aarch64-ovmf.text = lib.mkIf (!isServer) ''
      rm -f /run/libvirt/nix-ovmf/AAVMF_*
      mkdir -p /run/libvirt/nix-ovmf || true
      ${pkgs.zstd}/bin/zstd -d ${../misc/AAVMF_CODE.fd.zst} -o /run/libvirt/nix-ovmf/AAVMF_CODE.fd
      ${pkgs.zstd}/bin/zstd -d ${../misc/AAVMF_VARS.fd.zst} -o /run/libvirt/nix-ovmf/AAVMF_VARS.fd
    '';
  };
}
