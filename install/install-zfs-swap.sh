#! /usr/bin/env nix-shell
#! nix-shell -i bash -p gptfdisk parted git

set -e

CONFIG_FOLDER="$(dirname "$(pwd)")"
DEVICE_NAME=Hypervisor-VM
IS_VM=true
MAX_JOBS=4
USE_SWAP=true
SWAP_SIZE=1G
ZFS_ARC_MAX=4294967296

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
    if [[ -z "$IS_VM" ]]; then
        select ENTRY in $(ls /dev/disk/by-id/);
        do
            DISK="/dev/disk/by-id/$ENTRY"
            echo "Installing system on $ENTRY"
            break
        done
    else
        select ENTRY in $(ls /dev/disk/by-path/);
        do
            DISK="/dev/disk/by-path/$ENTRY"
            echo "Installing system on $ENTRY"
            break
        done
    fi

    read -s -p "> Do you want to wipe all data on $ENTRY ?" -n 1 -r
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]
    then
        sgdisk --zap-all "$DISK"
    fi

    pprint "Creating boot (EFI) partition"
    sgdisk -n1:1M:+512MiB -t1:EF00 "$DISK"
    BOOT="$DISK-part1"

    pprint "Creating ROOT partition"
    sgdisk -n2:0:0 -t2:BF00 "$DISK"
    ZFS="$DISK-part2"

    partprobe "$DISK"
    sleep 1

    pprint "Format BOOT partition $BOOT"
    mkfs.vfat -n EFI "$BOOT"
}

### INSTALLATION BEGIN ###
create_new_part_table

pprint "Create ZFS pool on $ZFS"
zpool create \
    -f \
    -o ashift=12 \
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

zfs create -o refreservation=10G -o mountpoint=none rpool/reserved
zfs create -o canmount=off -o mountpoint=none -o encryption=aes-256-gcm -o keyformat=passphrase -o keylocation=prompt rpool/enc
zfs create -o canmount=off -o mountpoint=none rpool/enc/nixos
zfs create -o canmount=off -o mountpoint=none rpool/enc/user
zfs create -o canmount=on -o mountpoint=/ rpool/enc/nixos/root
zfs create -o canmount=noauto -o mountpoint=/ rpool/enc/nixos/empty
zfs create -o canmount=on -o mountpoint=/nix rpool/enc/nixos/nix
zfs create -o canmount=on -o mountpoint=/home rpool/enc/user/home
zfs create -o canmount=off -o mountpoint=/var rpool/enc/nixos/var
zfs create -o canmount=on rpool/enc/nixos/var/lib
zfs create -o canmount=on rpool/enc/nixos/var/log
zfs create -o canmount=noauto -o atime=off rpool/enc/nixos/lxd
zfs create -o canmount=on -o mountpoint=/var/lib/docker -o atime=off rpool/enc/nixos/docker
zfs create -o canmount=on -o mountpoint=/media/bittorrent -o atime=off -o recordsize=256K rpool/enc/nixos/bittorrent
zfs create -o canmount=on -o mountpoint=/media/libvirt -o atime=off -o recordsize=64K rpool/enc/nixos/libvirt
# swap
if [[ "$USE_SWAP" = true ]]; then
    zfs create -V $SWAP_SIZE -b $(getconf PAGESIZE) -o logbias=throughput -o sync=always \
        -o primarycache=metadata -o secondarycache=none -o com.sun:auto-snapshot=false -o compression=zle rpool/enc/swap
    while [ ! -e /dev/zvol/rpool/enc/swap ]; do sleep 0.2; done
    mkswap -L swap -f /dev/zvol/rpool/enc/swap
    SWAP=/dev/zvol/rpool/enc/swap
fi

# Create blank zfs snapshot
zfs snapshot rpool/enc/nixos@blank
zfs snapshot rpool/enc/user@blank
zfs snapshot rpool/enc/nixos/empty@start

# Disable cache, stale cache will prevent system from booting
mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

mkdir /mnt/boot
mount "$BOOT" /mnt/boot

pprint "Generate NixOS configuration"
nixos-generate-config --root /mnt --dir $CONFIG_FOLDER/machines/$DEVICE_NAME
rm -f $CONFIG_FOLDER/machines/$DEVICE_NAME/configuration.nix

HOSTID=$(head -c8 /etc/machine-id)

HARDWARE_CONFIG=$(mktemp)
cat <<CONFIG > "$HARDWARE_CONFIG"
  networking.hostId = "$HOSTID";
  boot.zfs.devNodes = "$ZFS";
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = [ "zfs.zfs_arc_max=$ZFS_ARC_MAX" "nohibernate" ];
CONFIG

pprint "Append ZFS configuration to hardware-configuration.nix"
sed -i "\$e cat $HARDWARE_CONFIG" $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix

if [[ -n "$SWAP" ]]; then
    sed -i "s#swapDevices = \[ \];#swapDevices = \[\n    {\n      device = \"$SWAP\";\n    }\n  \];#" $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
fi

# pprint "Copy hardware config to machines folder"
# cp /mnt/etc/nixos/hardware-configuration.nix $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
chown 1000:100 $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
# Change <not-detected> for flakes
# sed -i "s#(modulesPath + \"/installer/scan/not-detected.nix\")#\"${toString modulesPath}/installer/scan/not-detected.nix\"#" $CONFIG_FOLDER/machines/$DEVICE_NAME/hardware-configuration.nix
git add -A

clean_stdin
read -s -p "> Do you want to execute nixos-install command?" -n 1 -r
echo
if [[ "$REPLY" =~ ^[Yy]$ ]]
then
    nixos-install --flake "../#$DEVICE_NAME" --max-jobs $MAX_JOBS --no-root-passwd
fi

pprint "Copy config to destination system"
mkdir -p /mnt/home/alukard/nixos-config
cp -aT $CONFIG_FOLDER /mnt/home/alukard/nixos-config

pprint "Gen ssh host key for initrd"
ssh-keygen -t ed25519 -N "" -f /mnt/root/ssh_host_key
chown root:root /mnt/root/ssh_host_key
cmod 644 /mnt/root/ssh_host_key

umount -Rl /mnt
zpool export -a