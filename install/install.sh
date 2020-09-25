#! /usr/bin/env nix-shell
#! nix-shell -i bash -p perl

set -e

CONFIG_FOLDER="$(dirname "$(pwd)")"
DEVICE_NAME=Dell-Laptop
MAX_JOBS=8
NIXOS_COMMIT="c59ea8b8a0e7f927e7291c14ea6cd1bd3a16ff38"
ZFS_ARC_MAX=4294967296 # Max ARC cache size. default = 4GiB
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
    sgdisk -n 2::+8GiB -t 2:8200 "$DISK"
    SWAP="$DISK-part2"

    pprint "Creating LUKS partition"
    sgdisk -n 3 -t 3:8309 "$DISK"
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

    pprint "Select the partition on which LUKS will be created"

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

read -p "> Do you want to partition the disk (new gpt table)?" -n 1 -r
echo
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    create_new_part_table
else
    use_old_part_table
fi

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

if [[ "$SWAP" != "NONE" ]]; then
    pprint "Create SWAP partition on $SWAP"
    mkswap $SWAP
fi

pprint "Create ZFS pool on $ZFS"
zpool create -f -m none -o ashift=$ZFS_ASHIFT -O compression=lz4 -O normalization=formD -O atime=on -O relatime=on -O dedup=off -R /mnt rpool "$ZFS"

pprint "Create ZFS datasets"

zfs create -o mountpoint=none -o com.sun.auto-snapshot=false rpool/local
zfs create -o mountpoint=legacy -o atime=off -o recordsize=16K rpool/local/bittorrent
zfs create -o mountpoint=legacy -o atime=off rpool/local/nix
zfs create -o mountpoint=none -o com.sun.auto-snapshot:frequent=false rpool/system
zfs create -o mountpoint=legacy rpool/system/root
zfs create -o mountpoint=legacy -o xattr=sa -o acltype=posixacl rpool/system/var
zfs create -o mountpoint=none rpool/user
zfs create -o mountpoint=legacy rpool/user/home

# Create blank zfs snapshot
zfs snapshot rpool/local@blank
zfs snapshot rpool/system@blank

pprint "Mount ZFS datasets"
mount -t zfs rpool/system/root /mnt

mkdir /mnt/nix
mount -t zfs rpool/local/nix /mnt/nix

mkdir /mnt/var
mount -t zfs rpool/system/var /mnt/var

mkdir /mnt/home
mount -t zfs rpool/user/home /mnt/home

mkdir /mnt/bittorrent
mount -t zfs rpool/local/bittorrent /mnt/bittorrent

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
cat <<CONFIG > "$HARDWARE_CONFIG"
  networking.hostId = "$HOSTID";
  boot.initrd.luks.devices."$LUKS_DEVICE_NAME".device = "/dev/disk/by-partuuid/$LINUX_DISK_UUID";
  boot.zfs.devNodes = "$ZFS";
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = [ "zfs.zfs_arc_max=$ZFS_ARC_MAX" ];
CONFIG

pprint "Append ZFS configuration to hardware-configuration.nix"
sed -i "\$e cat $HARDWARE_CONFIG" /mnt/etc/nixos/hardware-configuration.nix

if [[ "$SWAP" != "NONE" ]]; then
    perl -0777 -pi -e "s#swapDevices.+#swapDevices = [\n    {\n      device = \"/dev/disk/by-partuuid/$SWAP_UUID\";\n      randomEncryption.enable = true;\n    }\n  ];#" /mnt/etc/nixos/hardware-configuration.nix
fi

pprint "Copy minimal config to destiination system"
cp /mnt/etc/nixos/hardware-configuration.nix $CONFIG_FOLDER/hardware-configuration/$DEVICE_NAME.nix
# Change <not-detected> for flakes
sed -i 's#<nixpkgs/nixos/modules/installer/scan/not-detected.nix>#"${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix"#' $CONFIG_FOLDER/hardware-configuration/$DEVICE_NAME.nix
cp ./min-config.nix /mnt/etc/nixos/configuration.nix
sed -i "s#changeme#${DEVICE_NAME}#" /mnt/etc/nixos/configuration.nix

clean_stdin
read -p "> Do you want to execute nixos-install command?" -n 1 -r
echo
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    nixos-install -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/$NIXOS_COMMIT.tar.gz --max-jobs $MAX_JOBS --no-root-passwd
    mkdir -p /mnt/home/alukard/nixos-config
    cp -aT $CONFIG_FOLDER /mnt/home/alukard/nixos-config
fi
