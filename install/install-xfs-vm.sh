#! /usr/bin/env nix-shell
#! nix-shell -i bash -p perl -p gptfdisk -p parted -p git

set -e

CONFIG_FOLDER="$(dirname "$(pwd)")"
DEVICE_NAME=Wayland-VM
MAX_JOBS=4
SWAP_SIZE=2GiB

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

    wipefs -af "$DISK"
    sgdisk -Zo "$DISK"

    pprint "Creating boot (EFI) partition"
    sgdisk -n 1:1MiB:+128MiB -t 1:EF00 "$DISK"
    BOOT="$DISK-part1"

    pprint "Creating SWAP partition"
    sgdisk -n 2::+$SWAP_SIZE -t 2:8200 "$DISK"
    SWAP="$DISK-part2"

    pprint "Creating ROOT partition"
    sgdisk -n 3 -t 3:8300 "$DISK"
    LINUX="$DISK-part3"

    partprobe "$DISK"
    sleep 1

    pprint "Format BOOT partition $BOOT"
    mkfs.vfat "$BOOT"
}

### INSTALLATION BEGIN ###
create_new_part_table

LINUX_PARTUUID=$(blkid --match-tag PARTUUID --output value "$LINUX")
XFS="/dev/disk/by-partuuid/$LINUX_PARTUUID"

if [[ "$SWAP" != "NONE" ]]; then
    pprint "Create SWAP partition on $SWAP"
    mkswap $SWAP
fi

pprint "Create XFS partition on $XFS"
mkfs.xfs -L root -f "$XFS"

pprint "Mount XFS partition"
mkdir -p /mnt
mount -t xfs "$XFS" /mnt

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
  boot.initrd.supportedFilesystems = [ "xfs" ];
  boot.supportedFilesystems = [ "xfs" ];
CONFIG

pprint "Append XFS configuration to hardware-configuration.nix"
sed -i "\$e cat $HARDWARE_CONFIG" /mnt/etc/nixos/hardware-configuration.nix

if [[ "$SWAP" != "NONE" ]]; then
    perl -0777 -pi -e "s#swapDevices.+#swapDevices = [\n    {\n      device = \"/dev/disk/by-partuuid/$SWAP_UUID\";\n      randomEncryption.enable = true;\n    }\n  ];#" /mnt/etc/nixos/hardware-configuration.nix
fi

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
