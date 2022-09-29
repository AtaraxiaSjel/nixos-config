#! /usr/bin/env nix-shell
#! nix-shell -i bash -p perl -p gptfdisk -p parted -p git

set -e

CONFIG_FOLDER="$(dirname "$(pwd)")"
DEVICE_NAME=Testing-VM
MAX_JOBS=4
SWAP_SIZE=16GiB
USE_ECNRYPTION=false
ZFS_ARC_MAX=1073741824
# ZFS_ARC_MAX=8589934592 # 8GiB
# ZFS_ARC_MAX=4294967296 # Max ARC cache size. default = 4GiB
ZFS_ASHIFT=12 # recommended=12 which 1<<12 (4096)

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
    select ENTRY in $(ls /dev/disk/by-id/);
    do
        DISK="/dev/disk/by-id/$ENTRY"
        echo "Installing system on $ENTRY"
        break
    done

    read -p "> Do you want to wipe all data on $ENTRY ?" -n 1 -r
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]
    then
        wipefs -af "$DISK"
        sgdisk -Zo "$DISK"
    fi

    pprint "Creating boot (EFI) partition"
    sgdisk -n 1:1MiB:+256MiB -t 1:EF00 "$DISK"
    BOOT="$DISK-part1"

    pprint "Creating SWAP partition"
    sgdisk -n 2::+$SWAP_SIZE -t 2:8200 "$DISK"
    SWAP="$DISK-part2"

    if [[ "$USE_ECNRYPTION" = true ]]
    then
        pprint "Creating LUKS partition"
        sgdisk -n 3 -t 3:8309 "$DISK"
    else
        pprint "Creating ROOT partition"
        sgdisk -n 3 -t 3:BF00 "$DISK"
    fi
    LINUX="$DISK-part3"

    partprobe "$DISK"
    sleep 1

    pprint "Format BOOT partition $BOOT"
    mkfs.vfat "$BOOT"
}

# Using existed partitions
use_old_part_table() {
    lsblk -o name,type,size,mountpoint | grep part

    pprint "Select BOOT partition (must already be formatted in vfat!)"

    select ENTRY in $(lsblk -o path,size,type | grep part | awk '{print $1}');
    do
        BOOT="$ENTRY"
        echo "You select $BOOT as BOOT"
        break
    done

    if [[ "$USE_ECNRYPTION" = true ]]
    then
        pprint "Select the partition on which LUKS will be created"
    else
        pprint "Select the partition on which ROOT will be created"
    fi

    select ENTRY in $(lsblk -o path,size,type | grep part | awk '{print $1}');
    do
        LINUX="$ENTRY"
        echo "Installing system on $LINUX"
        break
    done

    pprint "Select the partition on which SWAP will be created"

    select ENTRY in $(lsblk -o path,size,type | grep part | awk '{print $1}' && echo NONE);
    do
        SWAP="$ENTRY"
        echo "You select $SWAP as SWAP"
        break
    done

    clean_stdin
    read -p "> Do you want to format BOOT partition in $BOOT?" -n 1 -r
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]
    then
        mkfs.vfat "$BOOT"
    fi
}

### INSTALLATION BEGIN ###

read -p "> Do you want to encrypt your disk with LUKS?" -n 1 -r
echo
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    USE_ECNRYPTION=true
else
    USE_ECNRYPTION=false
fi

read -p "> Do you want to partition the disk (new gpt table)?" -n 1 -r
echo
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    create_new_part_table
else
    use_old_part_table
fi

if [[ "$USE_ECNRYPTION" = true ]]
then
    pprint "Creating LUKS container on $LINUX"
    clean_stdin
    cryptsetup --type luks2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat "$LINUX"

    pprint "Open LUKS container on $LINUX"
    LUKS_DEVICE_NAME=cryptroot
    clean_stdin
    cryptsetup luksOpen "$LINUX" "$LUKS_DEVICE_NAME"

    LUKS_DISK="/dev/mapper/$LUKS_DEVICE_NAME"

    pprint "Create ZFS partition on $LUKS_DISK"
    ZFS="${LUKS_DISK}"
else
    LINUX_PARTUUID=$(blkid --match-tag PARTUUID --output value "$LINUX")
    ZFS="/dev/disk/by-partuuid/$LINUX_PARTUUID"
fi

if [[ "$SWAP" != "NONE" ]]; then
    pprint "Create SWAP partition on $SWAP"
    mkswap $SWAP
fi

pprint "Create ZFS pool on $ZFS"
zpool create \
    -f \
    -o ashift=$ZFS_ASHIFT \
    -o autotrim=on \
    -R /mnt \
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
    rpool "$ZFS"

pprint "Create ZFS datasets"

zfs create -o canmount=off -o mountpoint=none rpool/nixos
zfs create -o canmount=off -o mountpoint=none rpool/user
zfs create -o canmount=on -o mountpoint=/ rpool/nixos/root
zfs create -o canmount=noauto -o mountpoint=/ rpool/nixos/empty
zfs create -o canmount=on -o mountpoint=/nix rpool/nixos/nix
zfs create -o canmount=on -o mountpoint=/home rpool/user/home
zfs create -o canmount=off -o mountpoint=/var rpool/nixos/var
zfs create -o canmount=on rpool/nixos/var/lib
zfs create -o canmount=on rpool/nixos/var/log
zfs create -o canmount=on -o mountpoint=/media/bittorrent -o atime=off -o recordsize=256K rpool/nixos/bittorrent
zfs create -o canmount=on -o mountpoint=/media/libvirt -o atime=off -o recordsize=64K rpool/nixos/libvirt

# Create blank zfs snapshot
zfs snapshot rpool/nixos@blank
zfs snapshot rpool/user@blank
zfs snapshot rpool/nixos/empty@start

# Disable cache, stale cache will prevent system from booting
mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

mkdir /mnt/boot
mount "$BOOT" /mnt/boot

pprint "Generate NixOS configuration"
nixos-generate-config --root /mnt

HOSTID=$(head -c8 /etc/machine-id)
LINUX_DISK_UUID=$(blkid --match-tag PARTUUID --output value "$LINUX")
if [[ "$SWAP" != "NONE" ]]; then
    SWAP_UUID=$(blkid --match-tag PARTUUID --output value "$SWAP")
fi

HARDWARE_CONFIG=$(mktemp)
if [[ "$USE_ECNRYPTION" = true ]]
then
cat <<CONFIG > "$HARDWARE_CONFIG"
  networking.hostId = "$HOSTID";
  boot.initrd.luks.devices."$LUKS_DEVICE_NAME".device = "/dev/disk/by-partuuid/$LINUX_DISK_UUID";
  boot.zfs.devNodes = "$ZFS";
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = [ "zfs.zfs_arc_max=$ZFS_ARC_MAX" "nohibernate" ];
CONFIG
else
cat <<CONFIG > "$HARDWARE_CONFIG"
  networking.hostId = "$HOSTID";
  boot.zfs.devNodes = "$ZFS";
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = [ "zfs.zfs_arc_max=$ZFS_ARC_MAX" "nohibernate" ];
CONFIG
fi

pprint "Append ZFS configuration to hardware-configuration.nix"
sed -i "\$e cat $HARDWARE_CONFIG" /mnt/etc/nixos/hardware-configuration.nix
sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' /mnt/etc/nixos/hardware-configuration.nix

if [[ "$SWAP" != "NONE" ]]; then
    perl -0777 -pi -e "s#swapDevices.+#swapDevices = [\n    {\n      device = \"/dev/disk/by-partuuid/$SWAP_UUID\";\n      randomEncryption.enable = true;\n    }\n  ];#" /mnt/etc/nixos/hardware-configuration.nix
fi

pprint "Copy hardware config to machines folder"
cp /mnt/etc/nixos/hardware-configuration.nix $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
chown 1000:users ../machines/$DEVICE_NAME/hardware-configuration.nix
# Change <not-detected> for flakes
sed -i "s#<nixpkgs/nixos/modules/installer/scan/not-detected.nix>#\"\${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix\"#" $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
git add -A

clean_stdin
read -p "> Do you want to execute nixos-install command?" -n 1 -r
echo
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    nixos-install --flake "../#$DEVICE_NAME" --max-jobs $MAX_JOBS --no-root-passwd --impure
fi

pprint "Copy config to destination system"
mkdir -p /mnt/home/alukard/nixos-config
cp -aT $CONFIG_FOLDER /mnt/home/alukard/nixos-config