{ inputs, ... }:
let
  emptySnapshot =
    name: "zfs list -t snapshot -H -o name | grep -E '^${name}@blank$' || zfs snapshot ${name}@blank";
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_960_EVO_250GB_S3ESNX0K159868B";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              type = "EF00";
              name = "ESP";
              size = "512M";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/efi";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              name = "swap";
              size = "16G";
              priority = 2;
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            boot = {
              name = "bpool";
              size = "2G";
              priority = 3;
              content = {
                type = "zfs";
                pool = "bpool";
              };
            };
            cryptroot = {
              size = "100%";
              priority = 4;
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
    };
    zpool = {
      bpool = {
        type = "zpool";
        options = {
          ashift = "13";
          autotrim = "on";
          compatibility = "grub2";
        };
        rootFsOptions = {
          acltype = "posixacl";
          atime = "on";
          canmount = "off";
          compression = "lz4";
          devices = "off";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          dedup = "off";
        };
        mountpoint = "/boot";
        postCreateHook = emptySnapshot "bpool";

        datasets = {
          nixos = {
            type = "zfs_fs";
            options.mountpoint = "none";
            options.canmount = "off";
            postCreateHook = emptySnapshot "bpool/nixos";
          };
          "nixos/boot" = {
            type = "zfs_fs";
            mountpoint = "/boot";
            options.canmount = "on";
            postCreateHook = emptySnapshot "bpool/nixos/boot";
          };
        };
      };
      rpool = {
        type = "zpool";
        options = {
          ashift = "13";
          autotrim = "on";
          cachefile = "none";
        };
        rootFsOptions = {
          acltype = "posixacl";
          atime = "on";
          canmount = "off";
          compression = "zstd";
          dedup = "off";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
        };
        mountpoint = "/";
        postCreateHook = emptySnapshot "rpool";

        datasets = {
          reserved = {
            type = "zfs_fs";
            options.mountpoint = "none";
            options = {
              canmount = "off";
              refreservation = "10G";
            };
          };
          nixos = {
            type = "zfs_fs";
            options.mountpoint = "none";
            options.canmount = "off";
            postCreateHook = emptySnapshot "rpool/nixos";
          };
          user = {
            type = "zfs_fs";
            options.mountpoint = "none";
            options.canmount = "off";
            postCreateHook = emptySnapshot "rpool/user";
          };
          persistent = {
            type = "zfs_fs";
            options.mountpoint = "none";
            options.canmount = "off";
            postCreateHook = emptySnapshot "rpool/persistent";
          };
          "nixos/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.canmount = "noauto";
            postCreateHook = emptySnapshot "rpool/nixos/root";
          };
          "user/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/user/home";
          };
          "persistent/impermanence" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/impermanence";
          };
          "persistent/servers" = {
            type = "zfs_fs";
            mountpoint = "/srv";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/servers";
          };
          "persistent/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/nix";
          };
          "persistent/secrets" = {
            type = "zfs_fs";
            mountpoint = "/etc/secrets";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/secrets";
          };
          "persistent/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/log";
          };
          "persistent/docker" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/docker";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/docker";
          };
          "persistent/nixos-containers" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/nixos-containers";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/nixos-containers";
          };
          "persistent/libvirt" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/libvirt";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/libvirt";
          };
          "persistent/libvirt-user" = {
            type = "zfs_fs";
            mountpoint = "/media/libvirt";
            options.canmount = "on";
            postCreateHook = emptySnapshot "rpool/persistent/libvirt-user";
          };
          "persistent/libvirt-user/images" = {
            type = "zfs_fs";
            mountpoint = "/media/libvirt/images";
            options.canmount = "on";
            options.atime = "off";
            options.recordsize = "16K";
            options.compression = "lz4";
            postCreateHook = emptySnapshot "rpool/persistent/libvirt-user/images";
          };
          "persistent/containers" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/containers";
            options.canmount = "on";
            options.atime = "off";
            postCreateHook = emptySnapshot "rpool/persistent/containers";
          };
          "persistent/postgresql" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/postgresql";
            options.canmount = "on";
            options.recordsize = "16K";
            options.atime = "off";
            options.logbias = "latency";
            postCreateHook = emptySnapshot "rpool/persistent/postgresql";
          };
        };
      };
    };
  };
}
