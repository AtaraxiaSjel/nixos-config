{ lib, ... }: {
  disko.devices.disk.disk1 = {
    device = lib.mkDefault "/dev/sda";
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
          size = "2G";
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
              mount -t btrfs /dev/sda4 /mnt
              btrfs subvolume snapshot -r /mnt/rootfs /mnt/snapshots/rootfs-blank
              btrfs subvolume snapshot -r /mnt/persistent/home /mnt/snapshots/home-blank
              btrfs subvolume snapshot -r /mnt/persistent/docker /mnt/snapshots/docker-blank
              btrfs subvolume snapshot -r /mnt/persistent/podman /mnt/snapshots/podman-blank
              btrfs subvolume snapshot -r /mnt/persistent/containers /mnt/snapshots/containers-blank
              btrfs subvolume snapshot -r /mnt/persistent/libvirt /mnt/snapshots/libvirt-blank
              btrfs subvolume snapshot -r /mnt/persistent/log /mnt/snapshots/log-blank
              btrfs subvolume snapshot -r /mnt/persistent/impermanence /mnt/snapshots/impermanence-blank
              btrfs subvolume snapshot -r /mnt/persistent/srv /mnt/snapshots/srv-blank
              umount /mnt
            '';
            subvolumes = {
              "/snapshots" = { };
              "/rootfs" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent" = { };
              "/persistent/nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent/home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent/srv" = {
                mountpoint = "/srv";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent/docker" = {
                mountpoint = "/var/lib/docker";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent/podman" = {
                mountpoint = "/var/lib/podman";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent/containers" = {
                mountpoint = "/var/lib/containers";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent/libvirt" = {
                mountpoint = "/var/lib/libvirt";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent/log" = {
                mountpoint = "/var/log";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/persistent/impermanence" = {
                mountpoint = "/persist";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
            };
          };
        };

      };
    };
  };
}
