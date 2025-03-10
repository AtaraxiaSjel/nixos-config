{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices.disk.disk1 =
    let
      device = "/dev/sda";
      defaultMountOpts = [
        "compress=zstd"
        "noatime"
        "autodefrag"
        "ssd"
      ];
    in
    {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            name = "swap";
            size = "1G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              postCreateHook = ''
                mount -t btrfs ${device}4 /mnt
                btrfs subvolume snapshot -r /mnt/rootfs /mnt/snapshots/rootfs-blank
                btrfs subvolume snapshot -r /mnt/homefs /mnt/snapshots/homefs-blank
                btrfs subvolume snapshot -r /mnt/persist/docker /mnt/snapshots/docker-blank
                btrfs subvolume snapshot -r /mnt/persist/podman /mnt/snapshots/podman-blank
                btrfs subvolume snapshot -r /mnt/persist/containers /mnt/snapshots/containers-blank
                btrfs subvolume snapshot -r /mnt/persist/libvirt /mnt/snapshots/libvirt-blank
                btrfs subvolume snapshot -r /mnt/persist/log /mnt/snapshots/log-blank
                btrfs subvolume snapshot -r /mnt/persist/impermanence /mnt/snapshots/impermanence-blank
                btrfs subvolume snapshot -r /mnt/persist/srv /mnt/snapshots/srv-blank
                umount /mnt
              '';
              subvolumes = {
                "/snapshots" = { };
                "/rootfs" = {
                  mountpoint = "/";
                  mountOptions = defaultMountOpts;
                };
                "/homefs" = {
                  mountpoint = "/home";
                  mountOptions = defaultMountOpts;
                };
                "/persist" = { };
                "/persist/nix" = {
                  mountpoint = "/nix";
                  mountOptions = defaultMountOpts;
                };
                "/persist/srv" = {
                  mountpoint = "/srv";
                  mountOptions = defaultMountOpts;
                };
                "/persist/docker" = {
                  mountpoint = "/var/lib/docker";
                  mountOptions = defaultMountOpts;
                };
                "/persist/podman" = {
                  mountpoint = "/var/lib/podman";
                  mountOptions = defaultMountOpts;
                };
                "/persist/containers" = {
                  mountpoint = "/var/lib/containers";
                  mountOptions = defaultMountOpts;
                };
                "/persist/libvirt" = {
                  mountpoint = "/var/lib/libvirt";
                  mountOptions = defaultMountOpts;
                };
                "/persist/log" = {
                  mountpoint = "/var/log";
                  mountOptions = defaultMountOpts;
                };
                "/persist/impermanence" = {
                  mountpoint = "/persist";
                  mountOptions = defaultMountOpts;
                };
              };
            };
          };
        };
      };
    };
}
