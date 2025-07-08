{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-terminfo

    ./boot.nix
    ./disk-config.nix
    ./backups.nix
  ];

  ataraxia.defaults.role = "server";
  ataraxia.defaults.hardware.cpuVendor = "intel";
  ataraxia.defaults.hardware.gpuVendor = "intel";
  # Impermanence
  ataraxia.filesystems.zfs.enable = true;
  ataraxia.filesystems.zfs.eraseOnBoot.enable = true;
  ataraxia.filesystems.zfs.eraseOnBoot.snapshots = [
    "rpool/nixos/root@empty"
    "rpool/user/home@empty"
  ];
  ataraxia.filesystems.zfs.mountpoints = [
    "/etc/secrets"
    "/media/libvirt"
    "/nix"
    "/persist"
    "/srv"
    "/var/lib/containers"
    "/etc/secrets"
    "/var/lib/docker"
    "/var/lib/libvirt"
    "/var/lib/nixos-containers"
    "/var/lib/postgresql"
    "/var/log"
    "/vol"
  ];

  ataraxia.networkd = {
    enable = true;
    domain = "home.ataraxiadev.com";
    ifname = "enp2s0";
    mac = "d4:3d:7e:26:a8:af";
    bridge.enable = true;
    ipv4 = [
      {
        address = "10.10.10.10/24";
        gateway = "10.10.10.1";
        dns = [
          "10.10.10.1"
          "9.9.9.9"
        ];
      }
    ];
  };

  security.lockKernelModules = lib.mkForce false;
  environment.memoryAllocator.provider = lib.mkForce "libc";

  # Services
  services.postgresql.enable = true;
  services.postgresql.settings = {
    full_page_writes = "off";
    wal_init_zero = "off";
    wal_recycle = "off";
  };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Auto-mount lan nfs share
  fileSystems."/media/local-nfs" = {
    device = "10.10.10.11:/";
    fsType = "nfs4";
    options = [
      "nfsvers=4.2"
      "x-systemd.automount"
      "noauto"
    ];
  };

  environment.systemPackages = with pkgs; [
    bat
    bottom
    dnsutils
    fd
    kitty.terminfo
    micro
    mkvtoolnix-cli
    nfs-utils
    p7zip
    podman-compose
    pwgen
    ripgrep
    rsync
    rustic-rs
    smartmontools
  ];

  system.stateVersion = "25.05";
}
