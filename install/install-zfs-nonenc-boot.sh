#! /usr/bin/env nix-shell
#! nix-shell -i bash -p gptfdisk parted git

set -e

CONFIG_FOLDER="$(dirname "$(pwd)")"
LUKS_DEVICE_NAME=cryptroot
DEVICE_NAME=Hypervisor-VM
# IS_VM=true
MAX_JOBS=2
USE_SWAP=true
BOOT_POOL_SIZE=4GiB
SWAP_SIZE=1GiB
BOOT_RESERVATION=128M
ROOT_RESERVATION=1G
USE_ECNRYPTION=true


if [[ "$IS_VM" = true ]]; then
    DISK_DEV_NODES="/dev/disk/by-path"
else
    DISK_DEV_NODES="/dev/disk/by-id"
fi

clean_stdin() {
	while read -r -t 0; do read -r; done
}

pprint () {
	local cyan="\e[96m"
	local default="\e[39m"
	local timestamp
	timestamp=$(date +%FT%T.%3NZ)
	echo -e "${cyan}${timestamp} $1${default}" 1>&2
}

# Create new partitions
create_new_part_table() {
    select ENTRY in $(ls $DISK_DEV_NODES);
    do
        DISK="$DISK_DEV_NODES/$ENTRY"
        echo "Installing system on $ENTRY"
        break
    done

    read -s -p "> Do you want to wipe all data on $ENTRY ?" -n 1 -r
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]
    then
        sgdisk --zap-all "$DISK"
    fi

    pprint "Creating boot (EFI) partition"
    sgdisk -n1:1MiB:+512MiB -t1:EF00 "$DISK"
    EFI="$DISK-part1"

    pprint "Creating boot (ZFS) partition"
    sgdisk -n2:0:+$BOOT_POOL_SIZE -t2:BF00 "$DISK"
    BOOT="$DISK-part2"

    if [[ "$USE_SWAP" = true ]]
    then
        pprint "Creating SWAP partition"
        sgdisk -n4:0:+$SWAP_SIZE -t4:8200 "$DISK"
    fi

    if [[ "$USE_ECNRYPTION" = true ]]
    then
        pprint "Creating LUKS partition"
        sgdisk -n3:0:0 -t3:8309 "$DISK"
    else
        pprint "Creating ROOT partition"
        sgdisk -n3:0:0 -t3:BF00 "$DISK"
    fi
    ROOT="$DISK-part3"

    partprobe "$DISK"
    sleep 1

    pprint "Format EFI partition $EFI"
    mkfs.vfat -n EFI "$EFI"
}

### INSTALLATION BEGIN ###
create_new_part_table

if [[ "$USE_ECNRYPTION" = true ]]
then
    dd if=/dev/urandom of=./keyfile0.bin bs=4096 count=4

    pprint "Creating LUKS container on $ROOT"
    clean_stdin
    cryptsetup --type luks2 --pbkdf argon2id -i 20 -c aes-xts-plain64 -s 512 -h sha256 luksFormat "$ROOT"
    clean_stdin
    pprint "Add keyfile to LUKS container on $ROOT"
    cryptsetup luksAddKey $ROOT keyfile0.bin

    pprint "Open LUKS container on $ROOT"
    cryptsetup luksOpen --allow-discards "$ROOT" "$LUKS_DEVICE_NAME" -d keyfile0.bin

    BOOT_POOL="$BOOT"
    ROOT_POOL="$(ls /dev/disk/by-id/dm-uuid-*$LUKS_DEVICE_NAME)"
else
    BOOT_POOL="$BOOT"
    ROOT_POOL="$ROOT"
fi

pprint "Create ZFS root pool on $ROOT_POOL"
zpool create \
    -f \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O atime=on \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O dedup=off \
    -O mountpoint=/ \
    -R /mnt \
    rpool "$ROOT_POOL"

pprint "Create ZFS root datasets"

zfs create -o refreservation=$ROOT_RESERVATION -o canmount=off -o mountpoint=none rpool/reserved
# top level datasets
zfs create -o canmount=off -o mountpoint=none rpool/nixos
zfs create -o canmount=off -o mountpoint=none rpool/user
zfs create -o canmount=off -o mountpoint=none rpool/persistent
# empty root
zfs create -o canmount=noauto -o mountpoint=/ rpool/nixos/root
zfs mount rpool/nixos/root
zfs create -o canmount=on -o mountpoint=/home rpool/user/home
# persistent across boots
zfs create -o canmount=on -o mountpoint=/persistent rpool/persistent/impermanence
zfs create -o canmount=on -o mountpoint=/etc/secrets rpool/persistent/secrets
zfs create -o canmount=on -o mountpoint=/nix rpool/persistent/nix
# zfs create -o canmount=on -o mountpoint=/boot rpool/persistent/boot
zfs create -o canmount=on -o mountpoint=/var/log rpool/persistent/log
zfs create -o canmount=noauto -o atime=off rpool/persistent/lxd
zfs create -o canmount=on -o mountpoint=/var/lib/docker -o atime=off rpool/persistent/docker
zfs create -o canmount=on -o mountpoint=/media/bittorrent -o atime=off -o recordsize=256K rpool/persistent/bittorrent
zfs create -o canmount=on -o mountpoint=/media/libvirt -o atime=off -o recordsize=64K rpool/persistent/libvirt

# Create empty zfs snapshots
zfs snapshot rpool/nixos@empty
zfs snapshot rpool/nixos/root@empty
zfs snapshot rpool/user@empty
zfs snapshot rpool/user/home@empty

pprint "Create ZFS boot pool on $BOOT_POOL"
zpool create \
    -f \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O atime=on \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O dedup=off \
    -O mountpoint=/boot \
    -R /mnt \
    bpool "$BOOT_POOL"

# zpool create \
#     -f \
#     -o ashift=12 \
#     -o autotrim=on \
#     -O acltype=posixacl \
#     -O atime=on \
#     -O canmount=off \
#     -O compression=zstd \
#     -O dnodesize=auto \
#     -O normalization=formD \
#     -O relatime=on \
#     -O xattr=sa \
#     -O dedup=off \
#     -O mountpoint=/boot \
#     -R /mnt \
#     bpool "$BOOT_POOL"

pprint "Create ZFS boot datasets"

zfs create -o refreservation=$BOOT_RESERVATION -o canmount=off -o mountpoint=none bpool/reserved
zfs create -o canmount=off -o mountpoint=none bpool/nixos
zfs create -o canmount=on -o mountpoint=/boot bpool/nixos/boot

zfs snapshot bpool/nixos@empty
zfs snapshot bpool/nixos/boot@empty

# Disable cache, stale cache will prevent system from booting
mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

mkdir -p /mnt/boot/efi
mount -t vfat "$EFI" /mnt/boot/efi

if [[ "$USE_SWAP" = true ]]; then
    SWAP="$DISK-part4"
    mkswap -L swap -f "$SWAP"
fi

pprint "Generate NixOS configuration"
[[ -f $CONFIG_FOLDER/machines/$DEVICE_NAME/configuration.nix ]] && CONFIG_EXISTS=true
nixos-generate-config --root /mnt --dir $CONFIG_FOLDER/machines/$DEVICE_NAME
[[ -z "$CONFIG_EXISTS" ]] && rm -f $CONFIG_FOLDER/machines/$DEVICE_NAME/configuration.nix

HOSTID=$(head -c8 /etc/machine-id)

ROOT_PARTUUID=$(blkid --match-tag PARTUUID --output value "$ROOT")
[[ ! -z "$SWAP" ]] && SWAP_PARTUUID=$(blkid --match-tag PARTUUID --output value "$SWAP")

HARDWARE_CONFIG=$(mktemp)
if [[ "$USE_ECNRYPTION" = true ]]
then
cat <<CONFIG > "$HARDWARE_CONFIG"
  networking.hostId = "$HOSTID";
  boot.zfs.devNodes = "$DISK_DEV_NODES";
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.luks.devices."$LUKS_DEVICE_NAME".device = "/dev/disk/by-partuuid/$ROOT_PARTUUID";
CONFIG
else
cat <<CONFIG > "$HARDWARE_CONFIG"
  networking.hostId = "$HOSTID";
  boot.zfs.devNodes = "$DISK_DEV_NODES";
  boot.supportedFilesystems = [ "zfs" ];
CONFIG
fi

pprint "Append ZFS configuration to hardware-configuration.nix"
sed -i "\$e cat $HARDWARE_CONFIG" $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
if [[ ! -z "$SWAP" ]]; then
    sed -i "s|swapDevices = \[ \];|swapDevices = \[\n    {\n      device = \"/dev/disk/by-partuuid/$SWAP_PARTUUID\";\n      randomEncryption.enable = true;\n      randomEncryption.allowDiscards = true;\n    }\n  \];|" $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
fi
chown 1000:100 $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
git add -A

pprint "Copy config to destination system"
mkdir -p /mnt/home/alukard/nixos-config
cp -aT $CONFIG_FOLDER /mnt/home/alukard/nixos-config

pprint "Gen ssh host key for initrd"
ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/ssh_host_key
chown root:root /mnt/etc/secrets/ssh_host_key
chmod 600 /mnt/etc/secrets/ssh_host_key

if [[ "$USE_ECNRYPTION" = true ]]
then
    cp keyfile0.bin /mnt/etc/secrets/keyfile0.bin
    chmod 000 /mnt/etc/secrets/keyfile*.bin
fi

clean_stdin
read -s -p "> Do you want to execute nixos-install command?" -n 1 -r
echo
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    nixos-install --flake "../#$DEVICE_NAME" --root /mnt --max-jobs $MAX_JOBS --no-root-passwd
fi

umount -Rl /mnt && \
zpool export -a && \
cryptsetup luksClose $LUKS_DEVICE_NAME
