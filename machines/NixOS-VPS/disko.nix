{ lib, disks ? [ "/dev/sda" ], ... }: {
  disk = lib.genAttrs disks (dev: {
    device = dev;
    type = "disk";
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "boot";
          start = "0";
          end = "1M";
          part-type = "primary";
          flags = [ "bios_grub" ];
        }
        {
          name = "ESP";
          start = "1MiB";
          end = "100MiB";
          bootable = true;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        }
        {
          name = "root";
          start = "100MiB";
          end = "-2G";
          part-type = "primary";
          bootable = true;
          # content = {
          #   type = "filesystem";
          #   format = "bcachefs";
          #   extraArgs = [
          #     "--block_size=8192"
          #     "--compression=zstd"
          #     "--discard"
          #     "--acl"
          #   ];
          #   mountpoint = "/";
          # };
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/rootfs" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/home" = {
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
              "/nix" = {
                mountOptions = [ "compress=zstd" "noatime" "autodefrag" "ssd" ];
              };
            };
          };
        }
        {
          name = "swap";
          start = "-2G";
          end = "100%";
          part-type = "primary";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        }
      ];
    };
  });
}
