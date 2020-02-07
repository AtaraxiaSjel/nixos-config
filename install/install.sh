#!/usr/bin/env bash
cd ..
CONFIG_FOLDER=$(pwd)
cd install

ENCRYPT_ROOT=true
FORMAT_BOOT_PARTITION=false

DEVICE_NAME=Dell-Laptop
DEVICE=/dev/nvme0n1
BOOT_PARTITION=/dev/nvme0n1p1
SWAP_PARTITION=/dev/nvme0n1p3
ROOT_PARTITION=/dev/nvme0n1p2
ROOT_NAME=cryptnixos

gdisk $DEVICE

# Format boot partition
if [[ "$FORMAT_BOOT_PARTITION" == true ]]; then
  mkfs.vfat -n BOOT $BOOT_PARTITION
fi
# Create luks partition
if [[ "$ENCRYPT_ROOT" == true ]]; then
  cryptsetup --type luks2 --cipher aes-xts-plain64 --key-size 256 --hash sha512 luksFormat $ROOT_PARTITION
  cryptsetup luksOpen --type luks2 $ROOT_PARTITION $ROOT_NAME
  ROOT_NAME=/dev/mapper/$ROOT_NAME
  mkfs.btrfs -f -L root $ROOT_NAME
  mount -t btrfs -o compress=zstd,noatime,ssd $ROOT_NAME /mnt
else
  ROOT_NAME=$ROOT_PARTITION
  mkfs.btrfs -f -L root $ROOT_PARTITION
  mount -t btrfs -o compress=zstd,noatime,ssd $ROOT_PARTITION /mnt
fi
btrfs subvolume create /mnt/@nixos
btrfs subvolume create /mnt/@nix-store
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt
mount -t btrfs -o subvol=@nixos,compress=zstd,noatime,ssd $ROOT_NAME /mnt/
mkdir -p /mnt/.snapshots
mkdir -p /mnt/home
mkdir -p /mnt/nix/store
mount -t btrfs -o subvol=@snapshots,compress=zstd,noatime,ssd $ROOT_NAME /mnt/.snapshots
mount -t btrfs -o subvol=@home,compress=zstd,noatime,ssd $ROOT_NAME /mnt/home
mount -t btrfs -o subvol=@nix-store,compress=zstd,noatime,ssd $ROOT_NAME /mnt/nix/store
btrfs subvolume create /mnt/tmp
btrfs subvolume create /mnt/var
# Mount boot
mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot
# Create swap
mkswap -L swap $SWAP_PARTITION
# Generate config (hardware)
nixos-generate-config --root /mnt/
echo "import $CONFIG_FOLDER \"$DEVICE_NAME\"" > /mnt/etc/nixos/configuration.nix
nano /mnt/etc/nixos/configuration.nix
read -p "Please, add swap device into nixos-config/modules/filesystems.nix before continue"
read -p "Press enter to continue"
nixos-install -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
mkdir -p /mnt/home/alukard/nixos-config
cp -aT $CONFIG_FOLDER /mnt/home/alukard/nixos-config
chown -R 1000:100 /mnt/home/alukard/nixos-config
echo "import /home/alukard/nixos-config \"$DEVICE_NAME\"" > /mnt/etc/nixos/configuration.nix
