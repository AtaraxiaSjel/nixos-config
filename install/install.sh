#!/usr/bin/env bash
ENCRYPT_ROOT=true
ENCRYPT_SWAP=false
FORMAT_BOOT_PARTITION=false

DEVICE_NAME=NixOS-VM
DEVICE=/dev/nvme0n1
BOOT_PARTITION=/dev/nvme0n1p1
SWAP_PARTITION=/dev/nvme0n1p3
ROOT_PARTITION=/dev/nvme0n1p2
SWAP_NAME=cryptswap
ROOT_NAME=cryptnixos


gdisk $DEVICE

# Format boot partition
if [[ "$FORMAT_BOOT_PARTITION" == true ]]; then
  mkfs.vfat -n BOOT $BOOT_PARTITION
fi
# Create luks partition
if [[ "$ENCRYPT_ROOT" == true ]]; then
  cryptsetup --type luks2 --cipher aes-xts-plain64 --key-size 256 --hash sha512 luksFormat $ROOT_PARTITION
  cryptsetup luksOpen $ROOT_PARTITION $ROOT_NAME
  mkfs.btrfs -f -L root /dev/mapper/$ROOT_NAME
else
  mkfs.btrfs -f -L root $ROOT_PARTITION
fi
# read -p "Press enter to continue"
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
# read -p "Press enter to continue"
# Mount boot
mkdir /mnt/boot
mount $BOOT_PARTITION /mnt/boot
# read -p "Press enter to continue"
# Create swap
if [[ "$ENCRYPT_SWAP" == true ]]; then
  dd count=1 bs=256 if=/dev/urandom of=/mnt/root/swap.key
  cryptsetup --type luks2 --cipher aes-xts-plain64 --key-size 256 --hash sha512 --key-file /mnt/root/swap.key luksFormat $SWAP_PARTITION
  cryptsetup --key-file /mnt/root/swap.key luksOpen $SWAP_PARTITION $SWAP_NAME
  mkswap -L swap /dev/mapper/cryptswap
else
  mkswap -L swap $SWAP_PARTITION
fi
# Generate config (hardware)
nixos-generate-config --root /mnt/
# Copy config to new system
mkdir -p /mnt/root/nixos-config
cp -r $(pwd)/.. /mnt/root/nixos-config
echo "import /mnt/root/nixos-config \"$DEVICE_NAME\"" > /mnt/etc/nixos/configuration.nix
nano /mnt/etc/nixos/configuration.nix
sed -i 's/\/etc\/nixos/\/mnt\/etc\/nixos/g' /mnt/root/nixos-config/default.nix
read -p "Please, add swap device into nixos-config/modules/filesystems.nix before continue"
read -p "Press enter to continue"
nixos-install -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
sed -i 's/\/mnt\/etc\/nixos/\/etc\/nixos/g' /mnt/root/nixos-config/default.nix
sed -i 's/\/mnt\/root/\/root/g' /mnt/etc/nixos/configuration.nix
read -p "Installation complete!"
