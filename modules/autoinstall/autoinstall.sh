set -eux

# Make sure everything is defined as an env var
autoReboot="${autoReboot?}"
flakesPath="${flakesPath?}"
hostname="${hostname?}"
mainUser="${mainUser?}"
debug="${debug?}"
entireDisk="${entireDisk?}"
nullifyDisk="${nullifyDisk?}"
disk="${disk?}"
bootPartition="${bootPartition?}"
rootPartition="${rootPartition?}"
swapPartition="${swapPartition?}"
efiSize="${efiSize?}"
bootSize="${bootSize?}"
rootSize="${rootSize?}"
swapSize="${swapSize?}"
useEncryption="${useEncryption?}"
useSwap="${useSwap?}"
argonIterTime="${argonIterTime?}"
cryptrootName="${cryptrootName?}"
cryptbootName="${cryptbootName?}"
passwordFile="${passwordFile?}"
zfsAshift="${zfsAshift?}"
rootPoolReservation="${rootPoolReservation?}"
bootPoolReservation="${bootPoolReservation?}"
usePersistModule="${usePersistModule?}"
persistRoot="${persistRoot?}"
persistHome="${persistHome?}"
oldUefi="${oldUefi?}"

if [ "$debug" = "true" ]; then
cat >&2 << FIN
  autoReboot="${autoReboot}"
  flakesPath="${flakesPath}"
  hostname="${hostname}"
  mainUser="${mainUser}"
  debug="${debug}"
  entireDisk="${entireDisk}"
  nullifyDisk="${nullifyDisk}"
  disk="${disk}"
  bootPartition="${bootPartition}"
  rootPartition="${rootPartition}"
  swapPartition="${swapPartition}"
  efiSize="${efiSize}"
  bootSize="${bootSize}"
  rootSize="${rootSize}"
  swapSize="${swapSize}"
  useEncryption="${useEncryption}"
  useSwap="${useSwap}"
  argonIterTime="${argonIterTime}"
  cryptrootName="${cryptrootName}"
  cryptbootName="${cryptbootName}"
  passwordFile="${passwordFile}"
  zfsAshift="${zfsAshift}"
  rootPoolReservation="${rootPoolReservation}"
  bootPoolReservation="${bootPoolReservation}"
  usePersistModule="${usePersistModule}"
  persistRoot="${persistRoot}"
  persistHome="${persistHome}"
  oldUefi="${oldUefi}"
FIN
fi

if [ ! -d "${flakesPath}" ]; then
  pprint "flakesPath does not exists!"
  exit 2
fi

if [ "$useEncryption" = "true" && ! -f "${passwordFile}" ]; then
  pprint "passwordFile does not exists!"
  exit 2
fi

pprint () {
	local timestamp
	timestamp=$(date +%FT%T.%3NZ)
	echo -e "${timestamp} $1" 1>&2
}

create_new_part_table() {
  wack=0
  diskByID=""
  if echo $disk | grep '/dev/disk/by-id'; then
    diskByID=$disk
  else
    byid=$(find -L /dev/disk -samefile $disk | grep by-id)
    if [ "$byid" = "" ]; then
      pprint "fatal: Could not find a /dev/disk/by-id symlink for %s\n" "$disk"
      wack=1
    else
      diskByID=$byid
    fi
  fi

  if [ "$debug" = "true" ]; then
    cat >&2 << FIN
      diskByID=${diskByID}
FIN
  fi

  # The for loop has the actual output
  if [ "${wack}" -gt 0 ]; then
    exit 2
  fi

  if [ "$nullifyDisk" = "true" ]; then
    diskname=$(basename $(readlink -f ${diskByID}))
    isHDD=$(cat /sys/block/${diskname}/queue/rotational)
    if [ "$isHDD" = 1 ]; then
      cat /dev/zero > "$diskByID" || true
    else
      blkdiscard "$diskByID"
    fi
  fi

  # partitioning
  sgdisk --zap-all "$diskByID"

  pprint "Creating boot (EFI) partition"
  sgdisk -n1:1MiB:+$efiSize -t1:EF00 "$diskByID"
  efiPart="$diskByID-part1"

  pprint "Creating boot (ZFS) partition"
  if [ "$useEncryption" = "true" ]; then
    sgdisk -n2:0:+$bootSize -t2:8309 "$diskByID"
  else
    sgdisk -n2:0:+$bootSize -t2:BF00 "$diskByID"
  fi
  bootPart="$diskByID-part2"

  if [ "$useSwap" = "true" ]; then
    pprint "Creating SWAP partition"
    sgdisk -n4:0:+$swapSize -t4:8200 "$diskByID"
    swapPart="$diskByID-part4"
  fi

  if [ "$useEncryption" = "true" ]; then
    pprint "Creating LUKS partition"
    sgdisk -n3:0:$rootSize -t3:8309 "$diskByID"
  else
    pprint "Creating ROOT partition"
    sgdisk -n3:0:$rootSize -t3:BF00 "$diskByID"
  fi
  rootPart="$diskByID-part3"

  partprobe "$diskByID"
  sleep 1

  pprint "Format EFI partition $efiPart"
  mkfs.vfat -n EFI "$efiPart"
}


# Installation begin
if [ "$entireDisk" = "true" ]; then
  create_new_part_table
else
  use_existing_part_table
fi

if [ "$useEncryption" = "true" ]; then
  password=$(cat $passwordFile)
  dd if=/dev/urandom of=/tmp/keyfile0.bin bs=1024 count=4

  pprint "Creating LUKS container on $bootPart"
  echo -n "$password" | cryptsetup --type luks2 --pbkdf argon2id --iter-time $argonIterTime -c aes-xts-plain64 -s 512 -h sha256 luksFormat "$bootPart" -
  pprint "Add keyfile to LUKS container on $bootPart"
  echo -n "$password" | cryptsetup luksAddKey $bootPart /tmp/keyfile0.bin -

  pprint "Open LUKS container on $bootPart"
  cryptsetup luksOpen --allow-discards "$bootPart" "$cryptbootName" -d /tmp/keyfile0.bin

  pprint "Creating LUKS container on $rootPart"
  echo -n "$password" | cryptsetup --type luks2 --pbkdf argon2id --iter-time $argonIterTime -c aes-xts-plain64 -s 512 -h sha256 luksFormat "$rootPart" -
  pprint "Add keyfile to LUKS container on $rootPart"
  echo -n "$password" | cryptsetup luksAddKey $rootPart /tmp/keyfile0.bin -

  pprint "Open LUKS container on $rootPart"
  cryptsetup luksOpen --allow-discards "$rootPart" "$cryptrootName" -d /tmp/keyfile0.bin

  bootPool="$(ls /dev/disk/by-id/dm-uuid-*$cryptbootName)"
  rootPool="$(ls /dev/disk/by-id/dm-uuid-*$cryptrootName)"
else
  bootPool="$bootPart"
  rootPool="$rootPart"
fi

pprint "Create ZFS root pool on $rootPool"
zpool create \
  -f \
  -o ashift=$zfsAshift \
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
  rpool "$rootPool"

pprint "Create ZFS root datasets"

if [ "$rootPoolReservation" != "0" ]; then
  zfs create -o refreservation=$rootPoolReservation -o canmount=off -o mountpoint=none rpool/reserved
fi
# top level datasets
zfs create -o canmount=off -o mountpoint=none rpool/nixos
zfs create -o canmount=off -o mountpoint=none rpool/user
zfs create -o canmount=off -o mountpoint=none rpool/persistent
# empty root
zfs create -o canmount=noauto -o mountpoint=/ rpool/nixos/root
zfs mount rpool/nixos/root
zfs create -o canmount=on -o mountpoint=/home rpool/user/home
# persistent across boots
if [ "$usePersistModule" = "true" ]; then
  zfs create -o canmount=on -o mountpoint=$persistRoot rpool/persistent/impermanence
  mkdir -p /mnt$persistRoot$persistHome
  chown 1000:100 /mnt$persistRoot$persistHome
  chmod 755 /mnt$persistRoot$persistHome
fi
zfs create -o canmount=on -o mountpoint=/srv rpool/persistent/servers
zfs create -o canmount=on -o mountpoint=/etc/secrets rpool/persistent/secrets
zfs create -o canmount=on -o mountpoint=/nix rpool/persistent/nix
zfs create -o canmount=on -o mountpoint=/var/log rpool/persistent/log
zfs create -o canmount=noauto -o atime=off rpool/persistent/lxd
zfs create -o canmount=on -o mountpoint=/var/lib/docker -o atime=off rpool/persistent/docker
zfs create -o canmount=on -o mountpoint=/var/lib/podman -o atime=off rpool/persistent/podman
zfs create -o canmount=on -o mountpoint=/var/lib/nixos-containers -o atime=off rpool/persistent/nixos-containers
zfs create -o canmount=on -o mountpoint=/media/bittorrent -o atime=off -o recordsize=16K -o compression=lz4 rpool/persistent/bittorrent
chown 1000:100 /mnt/media/bittorrent
chmod 775 /mnt/media/bittorrent
zfs create -o canmount=on -o mountpoint=/media/libvirt -o atime=off -o recordsize=16K -o compression=lz4 rpool/persistent/libvirt
chown 1000:67 /mnt/media/libvirt
chmod 775 /mnt/media/libvirt

# Create empty zfs snapshots
zfs snapshot rpool/nixos@empty
zfs snapshot rpool/nixos/root@empty
zfs snapshot rpool/user@empty
zfs snapshot rpool/user/home@empty
zfs snapshot rpool/persistent@empty
zfs snapshot rpool/persistent/impermanence@empty
zfs snapshot rpool/persistent/servers@empty
zfs snapshot rpool/persistent/secrets@empty
zfs snapshot rpool/persistent/nix@empty
zfs snapshot rpool/persistent/log@empty
zfs snapshot rpool/persistent/lxd@empty
zfs snapshot rpool/persistent/docker@empty
zfs snapshot rpool/persistent/podman@empty
zfs snapshot rpool/persistent/nixos-containers@empty
zfs snapshot rpool/persistent/bittorrent@empty
zfs snapshot rpool/persistent/libvirt@empty


pprint "Create ZFS boot pool on $bootPool"
zpool create \
  -f \
  -o compatibility=grub2 \
  -o ashift=$zfsAshift \
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
  bpool "$bootPool"

pprint "Create ZFS boot datasets"

if [ "$bootPoolReservation" != "0" ]; then
  zfs create -o refreservation=$bootPoolReservation -o canmount=off -o mountpoint=none bpool/reserved
fi
zfs create -o canmount=off -o mountpoint=none bpool/nixos
zfs create -o canmount=on -o mountpoint=/boot bpool/nixos/boot

zfs snapshot bpool/nixos@empty
zfs snapshot bpool/nixos/boot@empty

# Disable cache, stale cache will prevent system from booting
if [ "$usePersistModule" = "true" ]; then
    mkdir -p /mnt"$persistRoot"/etc/zfs/
    rm -f /mnt"$persistRoot"/etc/zfs/zpool.cache
    touch /mnt"$persistRoot"/etc/zfs/zpool.cache
    chmod a-w /mnt"$persistRoot"/etc/zfs/zpool.cache
    chattr +i /mnt"$persistRoot"/etc/zfs/zpool.cache
else
    mkdir -p /mnt/etc/zfs/
    rm -f /mnt/etc/zfs/zpool.cache
    touch /mnt/etc/zfs/zpool.cache
    chmod a-w /mnt/etc/zfs/zpool.cache
    chattr +i /mnt/etc/zfs/zpool.cache
fi

mkdir -p /mnt/boot/efi
mount -t vfat "$efiPart" /mnt/boot/efi

if [ "$useSwap" = "true" ]; then
    mkswap -L swap -f "$swapPart"
fi

pprint "Generate NixOS configuration"
configExists=false
[ -f $flakesPath/machines/$hostname/configuration.nix ] && configExists=true
nixos-generate-config --root /mnt --dir $flakesPath/machines/$hostname
[ "$configExists" = "false" ] && rm -f $flakesPath/machines/$hostname/configuration.nix

pprint "Append ZFS configuration to hardware-configuration.nix"

hostID=$(head -c8 /etc/machine-id)

hardwareConfig=$(mktemp)
if [ "$useEncryption" = "true" ]; then
  bootPartUuid=$(blkid --match-tag PARTUUID --output value "$bootPart")
  rootPartUuid=$(blkid --match-tag PARTUUID --output value "$rootPart")

  cat <<CONFIG > "$hardwareConfig"
    networking.hostId = "$hostID";
    boot.zfs.devNodes = "/dev/disk/by-id";
    boot.supportedFilesystems = [ "zfs" ];
    boot.initrd.luks.devices."$cryptbootName".device = "/dev/disk/by-partuuid/$bootPartUuid";
    boot.initrd.luks.devices."$cryptrootName".device = "/dev/disk/by-partuuid/$rootPartUuid";
CONFIG
else
cat <<CONFIG > "$hardwareConfig"
  networking.hostId = "$hostID";
  boot.zfs.devNodes = "/dev/disk/by-id";
  boot.supportedFilesystems = [ "zfs" ];
CONFIG
fi

sed -i "\$e cat $hardwareConfig" $flakesPath/machines/$hostname/hardware-configuration.nix
sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' $flakesPath/machines/$hostname/hardware-configuration.nix
if [ "$useSwap" == "true" ]; then
  swapPartUuid=$(blkid --match-tag PARTUUID --output value "$swapPart")
  sed -i "s|swapDevices = \[ \];|swapDevices = \[\n    {\n      device = \"/dev/disk/by-partuuid/$swapPartUuid\";\n      randomEncryption.enable = true;\n      randomEncryption.allowDiscards = true;\n    }\n  \];|" $flakesPath/machines/$hostname/hardware-configuration.nix
fi
chown 1000:100 $flakesPath/machines/$hostname/hardware-configuration.nix
git config --global --add safe.directory "$flakesPath"
git -C "$flakesPath" add -A

pprint "Gen ssh host key for initrd"
ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/ssh_host_key
chown root:root /mnt/etc/secrets/ssh_host_key
chmod 600 /mnt/etc/secrets/ssh_host_key

if [ "$useEncryption" = "true" ]; then
  cp /tmp/keyfile0.bin /mnt/etc/secrets/keyfile0.bin
  chmod 000 /mnt/etc/secrets/keyfile*.bin
fi

if [ "$debug" != "true" ]; then
  nixos-install --flake "$flakesPath/#$hostname" --root /mnt --no-root-passwd

  configPath="/mnt/persist/home/"$mainUser"/nixos-config"
  if [ ! -d "$configPath" ]; then
    mkdir -p $configPath
    chown 1000:100 $configPath
  fi
  cp -aT $flakesPath $configPath
fi

if [ "$oldUefi" = "true" ]; then
  mkdir -p /mnt/boot/efi/EFI/Microsoft/Boot
  cp /mnt/boot/efi/EFI/BOOT/BOOTX64.EFI /mnt/boot/efi/EFI/Microsoft/Boot/bootmgr.efi
  cp /mnt/boot/efi/EFI/BOOT/BOOTX64.EFI /mnt/boot/efi/EFI/Microsoft/Boot/bootmgfw.efi
fi

umount -Rl /mnt
zpool export -a
if [ "$useEncryption" = "true" ]; then
  cryptsetup luksClose $cryptbootName
  cryptsetup luksClose $cryptrootName
fi

if [ "$autoReboot" = "true" ]; then
  if ! systemctl reboot --firmware-setup ; then
    pprint "Reboot into efi firmware setup failed! Shutdown in 30 seconds"
    sleep 30
    systemctl poweroff
  fi
fi