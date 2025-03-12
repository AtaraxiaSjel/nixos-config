{ ... }:
{
  ataraxia.defaults.role = "server";
  # Impermanence
  ataraxia.filesystems.zfs.eraseOnBoot.enable = true;
  ataraxia.filesystems.zfs.eraseOnBoot.snapshots = [
    "rpool/nixos/root@blank"
    "rpool/user/home@blank"
  ];
  ataraxia.filesystems.zfs.mountpoints = [
    "/etc/secrets"
    "/media/bittorrent"
    "/media/libvirt"
    "/media/libvirt/images"
    "/nix"
    "/persist"
    "/srv/home"
    "/var/lib/docker"
    "/var/lib/libvirt"
    "/var/lib/nixos-containers"
    "/var/lib/ocis"
    "/var/lib/postgresql"
    "/var/log"
    "/vol"
  ];
}
