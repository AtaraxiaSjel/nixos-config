#!/usr/bin/env bash
DEVICE=/dev/nvme0n1
BOOT_PARTITION=/dev/nvme0n1p1
SWAP_PARTITION=/dev/nvme0n1p2
ROOT_PARTITION=/dev/nvme0n1p3

gdisk $DEVICE

mkfs.vfat -n BOOT $BOOT_PARTITION
mkfs.btrfs -f -L root $ROOT_PARTITION
mkswap -L swap $SWAP_PARTITION

mount -t btrfs $ROOT_PARTITION /mnt/
btrfs subvolume create /mnt/nixos
umount /mnt/
mount -t btrfs -o subvol=nixos,compress=zstd,noatime,discard,ssd $ROOT_PARTITION /mnt/
btrfs subvolume create /mnt/var
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/tmp

mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot

nixos-generate-config --root /mnt/

cp ./min-config.nix /mnt/etc/nixos/configuration.nix

nano /mnt/etc/nixos/configuration.nix
nixos-install -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
