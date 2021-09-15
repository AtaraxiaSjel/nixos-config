#! /usr/bin/env nix-shell
#! nix-shell -i bash -p perl -p gptfdisk -p parted

set -e

CONFIG_FOLDER="$(dirname "$(pwd)")"
DEVICE_NAME=AMD-Workstation
MAX_JOBS=12
SWAP_SIZE=16GiB
NIXOS_COMMIT="364b5555ee04bf61ee0075a3adab4c9351a8d38c"
USE_ECNRYPTION=false

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
        sgdisk -n 3 -t 3:8300 "$DISK"
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

    pprint "Create BTRFS partition on $LUKS_DISK"
    BTRFS="${LUKS_DISK}"
else
    LINUX_PARTUUID=$(blkid --match-tag PARTUUID --output value "$LINUX")
    BTRFS="/dev/disk/by-partuuid/$LINUX_PARTUUID"
fi

if [[ "$SWAP" != "NONE" ]]; then
    pprint "Create SWAP partition on $SWAP"
    mkswap $SWAP
fi

pprint "Create BTRFS partition on $BTRFS"
mkfs.btrfs -L root -f "$BTRFS"

pprint "Mount BTRFS partition"
mkdir -p /mnt
mount -t btrfs "$BTRFS" /mnt

pprint "Create and mount BTRFS subvolumes"
btrfs subvolume create /mnt/nixos
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/var
btrfs subvolume create /mnt/bittorrent
btrfs subvolume create /mnt/libvirt

umount /mnt

mount -t btrfs -o subvol=nixos,compress-force=zstd,noatime,autodefrag,ssd "$BTRFS" /mnt
mkdir -p /mnt/nix
mount -t btrfs -o subvol=nix,compress-force=zstd,noatime,autodefrag,ssd "$BTRFS" /mnt/nix
mkdir -p /mnt/home
mount -t btrfs -o subvol=home,compress-force=zstd,noatime,autodefrag,ssd "$BTRFS" /mnt/home
mkdir -p /mnt/var
mount -t btrfs -o subvol=var,compress-force=zstd,noatime,autodefrag,ssd "$BTRFS" /mnt/var
mkdir -p /mnt/media/bittorrent
mount -t btrfs -o subvol=bittorrent,nodatacow,ssd "$BTRFS" /mnt/media/bittorrent
mkdir -p /mnt/media/libvirt
mount -t btrfs -o subvol=libvirt,nodatacow,ssd "$BTRFS" /mnt/media/libvirt

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
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems = [ "btrfs" ];
CONFIG
else
cat <<CONFIG > "$HARDWARE_CONFIG"
  networking.hostId = "$HOSTID";
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems = [ "btrfs" ];
CONFIG
fi

pprint "Append BTRFS configuration to hardware-configuration.nix"
sed -i "\$e cat $HARDWARE_CONFIG" /mnt/etc/nixos/hardware-configuration.nix

if [[ "$SWAP" != "NONE" ]]; then
    perl -0777 -pi -e "s#swapDevices.+#swapDevices = [\n    {\n      device = \"/dev/disk/by-partuuid/$SWAP_UUID\";\n      randomEncryption.enable = true;\n    }\n  ];#" /mnt/etc/nixos/hardware-configuration.nix
fi

sed -i "s#\"subvol=nixos\"#\"subvol=nixos\" \"compress-force=zstd\" \"noatime\" \"autodefrag\" \"ssd\"#" /mnt/etc/nixos/hardware-configuration.nix
sed -i "s#\"subvol=home\"#\"subvol=home\" \"compress-force=zstd\" \"noatime\" \"autodefrag\" \"ssd\"#" /mnt/etc/nixos/hardware-configuration.nix
sed -i "s#\"subvol=nix\"#\"subvol=nix\" \"compress-force=zstd\" \"noatime\" \"autodefrag\" \"ssd\"#" /mnt/etc/nixos/hardware-configuration.nix
sed -i "s#\"subvol=var\"#\"subvol=var\" \"compress-force=zstd\" \"noatime\" \"autodefrag\" \"ssd\"#" /mnt/etc/nixos/hardware-configuration.nix
sed -i "s#\"subvol=bittorrent\"#\"subvol=bittorrent\" \"nodatacow\" \"ssd\"#" /mnt/etc/nixos/hardware-configuration.nix
sed -i "s#\"subvol=libvirt\"#\"subvol=libvirt\" \"nodatacow\" \"ssd\"#" /mnt/etc/nixos/hardware-configuration.nix

pprint "Copy minimal config to destination system"
cp /mnt/etc/nixos/hardware-configuration.nix $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
# Change <not-detected> for flakes
sed -i "s#<nixpkgs/nixos/modules/installer/scan/not-detected.nix>#\"\${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix\"#" $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
cp ./min-config.nix /mnt/etc/nixos/configuration.nix
sed -i "s/changeme/$DEVICE_NAME/" /mnt/etc/nixos/configuration.nix

clean_stdin
read -p "> Do you want to execute nixos-install command?" -n 1 -r
echo
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    nixos-install -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$NIXOS_COMMIT.tar.gz --max-jobs $MAX_JOBS --no-root-passwd
fi

pprint "Copy config to destination system"
mkdir -p /mnt/home/alukard/nixos-config
cp -aT $CONFIG_FOLDER /mnt/home/alukard/nixos-config
