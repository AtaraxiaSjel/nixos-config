#!/usr/bin/env bash
DEVICE=/dev/nvme0n1
BOOT_PARTITION=/dev/nvme0n1p1
SWAP_PARTITION=/dev/nvme0n1p3
ROOT_PARTITION=/dev/nvme0n1p2
SWAP_NAME=cryptswap
ROOT_NAME=cryptnixos

gdisk $DEVICE

# mkfs.vfat -n BOOT $BOOT_PARTITION
cryptsetup --type luks2 --cipher aes-xts-plain64 --key-size 256 --hash sha512 luksFormat $ROOT_PARTITION
cryptsetup luksOpen $ROOT_PARTITION $ROOT_NAME
mkfs.btrfs -f -L root /dev/mapper/$ROOT_NAME
mount -t btrfs -o compress=zstd,noatime,ssd /dev/mapper/$ROOT_NAME /mnt
btrfs subvolume create /mnt/@nixos
btrfs subvolume create /mnt/@nix-store
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt
mount -t btrfs -o subvol=@nixos,compress=zstd,noatime,ssd /dev/mapper/$ROOT_NAME /mnt/
mkdir -p /mnt/.snapshots
mkdir -p /mnt/home
mkdir -p /mnt/nix/store
mount -t btrfs -o subvol=@snapshots,compress=zstd,noatime,ssd /dev/mapper/$ROOT_NAME /mnt/.snapshots
mount -t btrfs -o subvol=@home,compress=zstd,noatime,ssd /dev/mapper/$ROOT_NAME /mnt/home
mount -t btrfs -o subvol=@nix-store,compress=zstd,noatime,ssd /dev/mapper/$ROOT_NAME /mnt/nix/store
btrfs subvolume create /mnt/tmp
btrfs subvolume create /mnt/var
mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot
# create swap
dd count=1 bs=256 if=/dev/urandom of=/mnt/root/swap.key
cryptsetup --type luks2 --cipher aes-xts-plain64 --key-size 256 --hash sha512 --key-file /mnt/root/swap.key luksFormat $SWAP_PARTITION
cryptsetup --key-file /mnt/root/swap.key luksOpen $SWAP_PARTITION $SWAP_NAME
mkswap -L swap /dev/mapper/cryptswap
swapon -L swap
nixos-generate-config --root /mnt/
cp ./min-config.nix /mnt/etc/nixos/configuration.nix
nano /mnt/etc/nixos/configuration.nix
read -p "Press enter to continue"
nixos-install -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
