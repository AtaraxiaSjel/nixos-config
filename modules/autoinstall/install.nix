{ opt, hostname, lib }:
with lib; let
  cfg = opt // {
    hostname = hostname;
    autoReboot = boolToString opt.autoReboot;
    entireDisk = boolToString opt.partitioning.useEntireDisk;
    nullifyDisk = boolToString opt.partitioning.nullifyDisk;
    disk = opt.partitioning.disk or "0";
    bootPartition = opt.partitioning.partitions.bootPartition or "0";
    rootPartition = opt.partitioning.partitions.rootPartition or "0";
    swapPartition = opt.partitioning.partitions.swapPartition or "0";
    emptySpace = opt.partitioning.emptySpace or "0";
    debug = boolToString opt.debug;
    useSwap = boolToString opt.swapPartition.enable;
    encryptRoot = boolToString opt.encryption.encryptRoot;
    encryptBoot = boolToString opt.encryption.encryptBoot;
    swapSize = opt.swapPartition.size or "0";
    zfsAshift = toString opt.zfsOpts.ashift;
    usePersistModule = boolToString opt.persist.enable;
    oldUefi = boolToString opt.oldUefi;
    argonIterTime = opt.encryption.argonIterTime;
    passwordFile = opt.encryption.passwordFile;
    cryptBoot = opt.encryption.cryptBoot;
    cryptRoot = opt.encryption.cryptRoot;
    bootPoolReservation = opt.zfsOpts.bootPoolReservation;
    rootPoolReservation = opt.zfsOpts.rootPoolReservation;
    persistRoot = opt.persist.persistRoot;
    persistHome = opt.persist.persistHome;
  };
in ''
  set -eux

  if [ "${cfg.debug}" = "true" ]; then
  cat >&2 << FIN
    autoReboot="${cfg.autoReboot}"
    flakesPath="${cfg.flakesPath}"
    hostname="${cfg.hostname}"
    mainuser="${cfg.mainuser}"
    debug="${cfg.debug}"
    entireDisk="${cfg.entireDisk}"
    nullifyDisk="${cfg.nullifyDisk}"
    disk="${cfg.disk}"
    bootPartition="${cfg.bootPartition}"
    rootPartition="${cfg.rootPartition}"
    swapPartition="${cfg.swapPartition}"
    efiSize="${cfg.efiSize}"
    bootSize="${cfg.bootSize}"
    rootSize="${cfg.rootSize}"
    swapSize="${cfg.swapSize}"
    encryptRoot="${cfg.encryptRoot}"
    encryptBoot="${cfg.encryptBoot}"
    useSwap="${cfg.useSwap}"
    argonIterTime="${cfg.argonIterTime}"
    cryptRoot="${cfg.cryptRoot}"
    cryptBoot="${cfg.cryptBoot}"
    passwordFile="${cfg.passwordFile}"
    zfsAshift="${cfg.zfsAshift}"
    rootPoolReservation="${cfg.rootPoolReservation}"
    bootPoolReservation="${cfg.bootPoolReservation}"
    usePersistModule="${cfg.usePersistModule}"
    persistRoot="${cfg.persistRoot}"
    persistHome="${cfg.persistHome}"
    oldUefi="${cfg.oldUefi}"
  FIN
  fi

  pprint () {
    local timestamp
    timestamp=$(date +%FT%T.%3NZ)
    echo -e "$timestamp $1" 1>&2
  }

  if [ ! -d "${cfg.flakesPath}" ]; then
    pprint "flakesPath does not exists!"
    exit 2
  fi

  if [ "${cfg.encryptBoot}" = "true" || "${cfg.encryptRoot}" = "true" && ! -f "${cfg.passwordFile}" ]; then
    pprint "passwordFile does not exists!"
    exit 2
  fi

  create_new_part_table() {
    wack=0
    diskByID=""
    if echo ${cfg.disk} | grep '/dev/disk/by-id'; then
      diskByID=${cfg.disk}
    else
      byid=$(find -L /dev/disk -samefile ${cfg.disk} | grep by-id)
      if [ "$byid" = "" ]; then
        pprint "fatal: Could not find a /dev/disk/by-id symlink for %s\n" "${cfg.disk}"
        wack=1
      else
        diskByID=$byid
      fi
    fi

    if [ "${cfg.debug}" = "true" ]; then
      cat >&2 << FIN
        diskByID=$diskByID
  FIN
    fi

    # The for loop has the actual output
    if [ "$wack" -gt 0 ]; then
      exit 2
    fi

    if [ "${cfg.nullifyDisk}" = "true" ]; then
      diskname=$(basename $(readlink -f $diskByID))
      isHDD=$(cat /sys/block/$diskname/queue/rotational)
      if [ "$isHDD" = 1 ]; then
        cat /dev/zero > "$diskByID" || true
      else
        blkdiscard "$diskByID"
      fi
    fi

    # partitioning
    sgdisk --zap-all "$diskByID"

    pprint "Creating boot (EFI) partition"
    sgdisk -n1:1MiB:+${cfg.efiSize} -t1:EF00 "$diskByID"
    efiPart="$diskByID-part1"

    pprint "Creating boot (ZFS) partition"
    if [ "${cfg.encryptBoot}" = "true" ]; then
      sgdisk -n2:0:+${cfg.bootSize} -t2:8309 "$diskByID"
    else
      sgdisk -n2:0:+${cfg.bootSize} -t2:BF00 "$diskByID"
    fi
    bootPart="$diskByID-part2"

    if [ "${cfg.emptySpace}" != "0" ]; then
      pprint "Creating temp empty partition at the end of the disk"
      sgdisk -n5:-${cfg.emptySpace}:0 -t5:8300 "$diskByID"
    fi

    if [ "${cfg.useSwap}" = "true" ]; then
      pprint "Creating SWAP partition"
      sgdisk -n4:0:+${cfg.swapSize} -t4:8200 "$diskByID"
      swapPart="$diskByID-part4"
    fi

    if [ "${cfg.encryptRoot}" = "true" ]; then
      pprint "Creating LUKS partition"
      sgdisk -n3:0:${cfg.rootSize} -t3:8309 "$diskByID"
    else
      pprint "Creating ROOT partition"
      sgdisk -n3:0:${cfg.rootSize} -t3:BF00 "$diskByID"
    fi
    rootPart="$diskByID-part3"

    if [ "${cfg.emptySpace}" != "0" ]; then
      pprint "Remove temp partition"
      sgdisk -d 5 -s "$diskByID"
    fi

    partprobe "$diskByID"
    sleep 1

    pprint "Format EFI partition $efiPart"
    mkfs.vfat -n EFI "$efiPart"
  }


  # Installation begin
  if [ "${cfg.entireDisk}" = "true" ]; then
    create_new_part_table
  else
    use_existing_part_table
  fi

  if [ "${cfg.encryptBoot}" = "true" || "${cfg.encryptRoot}" = "true" ]; then
    password=$(cat ${cfg.passwordFile})
    dd if=/dev/urandom of=/tmp/keyfile0.bin bs=1024 count=4

    if [ "${cfg.encryptBoot}" = "true" ]; then
      pprint "Creating LUKS container on $bootPart"
      echo -n "$password" | cryptsetup --type luks2 --pbkdf argon2id --iter-time ${cfg.argonIterTime} -c aes-xts-plain64 -s 512 -h sha256 luksFormat "$bootPart" -
      pprint "Add keyfile to LUKS container on $bootPart"
      echo -n "$password" | cryptsetup luksAddKey $bootPart /tmp/keyfile0.bin -

      pprint "Open LUKS container on $bootPart"
      cryptsetup luksOpen --allow-discards "$bootPart" "${cfg.cryptBoot}" -d /tmp/keyfile0.bin
      bootPool="$(ls /dev/disk/by-id/dm-uuid-*${cfg.cryptBoot})"
    fi

    if [ "${cfg.encryptRoot}" = "true" ]; then
      pprint "Creating LUKS container on $rootPart"
      echo -n "$password" | cryptsetup --type luks2 --pbkdf argon2id --iter-time ${cfg.argonIterTime} -c aes-xts-plain64 -s 512 -h sha256 luksFormat "$rootPart" -
      pprint "Add keyfile to LUKS container on $rootPart"
      echo -n "$password" | cryptsetup luksAddKey $rootPart /tmp/keyfile0.bin -

      pprint "Open LUKS container on $rootPart"
      cryptsetup luksOpen --allow-discards "$rootPart" "${cfg.cryptRoot}" -d /tmp/keyfile0.bin
      rootPool="$(ls /dev/disk/by-id/dm-uuid-*${cfg.cryptRoot})"
    fi
  else
    bootPool="$bootPart"
    rootPool="$rootPart"
  fi

  pprint "Create ZFS root pool on $rootPool"
  zpool create \
    -f \
    -o ashift=${cfg.zfsAshift} \
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

  if [ "${cfg.rootPoolReservation}" != "0" ]; then
    zfs create -o refreservation=${cfg.rootPoolReservation} -o canmount=off -o mountpoint=none rpool/reserved
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
  if [ "${cfg.usePersistModule}" = "true" ]; then
    zfs create -o canmount=on -o mountpoint=${cfg.persistRoot} rpool/persistent/impermanence
    mkdir -p /mnt${cfg.persistRoot}${cfg.persistHome}
    chown 1000:100 /mnt${cfg.persistRoot}${cfg.persistHome}
    chmod 755 /mnt${cfg.persistRoot}${cfg.persistHome}
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
    -o ashift=${cfg.zfsAshift} \
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

  if [ "${cfg.bootPoolReservation}" != "0" ]; then
    zfs create -o refreservation=${cfg.bootPoolReservation} -o canmount=off -o mountpoint=none bpool/reserved
  fi
  zfs create -o canmount=off -o mountpoint=none bpool/nixos
  zfs create -o canmount=on -o mountpoint=/boot bpool/nixos/boot

  zfs snapshot bpool/nixos@empty
  zfs snapshot bpool/nixos/boot@empty

  # Disable cache, stale cache will prevent system from booting
  if [ "${cfg.usePersistModule}" = "true" ]; then
      mkdir -p /mnt"${cfg.persistRoot}"/etc/zfs/
      rm -f /mnt"${cfg.persistRoot}"/etc/zfs/zpool.cache
      touch /mnt"${cfg.persistRoot}"/etc/zfs/zpool.cache
      chmod a-w /mnt"${cfg.persistRoot}"/etc/zfs/zpool.cache
      chattr +i /mnt"${cfg.persistRoot}"/etc/zfs/zpool.cache
  else
      mkdir -p /mnt/etc/zfs/
      rm -f /mnt/etc/zfs/zpool.cache
      touch /mnt/etc/zfs/zpool.cache
      chmod a-w /mnt/etc/zfs/zpool.cache
      chattr +i /mnt/etc/zfs/zpool.cache
  fi

  mkdir -p /mnt/boot/efi
  mount -t vfat "$efiPart" /mnt/boot/efi

  if [ "${cfg.useSwap}" = "true" ]; then
      mkswap -L swap -f "$swapPart"
  fi

  pprint "Generate NixOS configuration"
  configExists=false
  [ -f ${cfg.flakesPath}/machines/${cfg.hostname}/configuration.nix ] && configExists=true
  nixos-generate-config --root /mnt --dir ${cfg.flakesPath}/machines/${cfg.hostname}
  [ "$configExists" = "false" ] && rm -f ${cfg.flakesPath}/machines/${cfg.hostname}/configuration.nix

  pprint "Append ZFS configuration to hardware-configuration.nix"

  hostID=$(head -c8 /etc/machine-id)

  hardwareConfig=$(mktemp)
  cat <<CONFIG > "$hardwareConfig"
    networking.hostId = "$hostID";
    boot.zfs.devNodes = "/dev/disk/by-partuuid";
    boot.supportedFilesystems = [ "zfs" ];
  CONFIG
  if [ "${cfg.encryptBoot}" = "true" ]; then
    bootPartUuid=$(blkid --match-tag PARTUUID --output value "$bootPart")
    cat <<CONFIG >> "$hardwareConfig"
      boot.initrd.luks.devices."${cfg.cryptBoot}".device = "/dev/disk/by-partuuid/$bootPartUuid";
  CONFIG
  fi
  if [ "${cfg.encryptRoot}" = "true" ]; then
    rootPartUuid=$(blkid --match-tag PARTUUID --output value "$rootPart")
    cat <<CONFIG >> "$hardwareConfig"
      boot.initrd.luks.devices."${cfg.cryptRoot}".device = "/dev/disk/by-partuuid/$rootPartUuid";
  CONFIG
  fi

  sed -i "\$e cat $hardwareConfig" ${cfg.flakesPath}/machines/${cfg.hostname}/hardware-configuration.nix
  sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' ${cfg.flakesPath}/machines/${cfg.hostname}/hardware-configuration.nix
  if [ "${cfg.useSwap}" == "true" ]; then
    swapPartUuid=$(blkid --match-tag PARTUUID --output value "$swapPart")
    sed -i "s|swapDevices = \[ \];|swapDevices = \[\n    {\n      device = \"/dev/disk/by-partuuid/$swapPartUuid\";\n      randomEncryption.enable = true;\n      randomEncryption.allowDiscards = true;\n    }\n  \];|" ${cfg.flakesPath}/machines/${cfg.hostname}/hardware-configuration.nix
  fi
  chown 1000:100 ${cfg.flakesPath}/machines/${cfg.hostname}/hardware-configuration.nix
  git config --global --add safe.directory "${cfg.flakesPath}"
  git -C "${cfg.flakesPath}" add -A

  pprint "Gen ssh host key for initrd"
  ssh-keygen -t ed25519 -N "" -f /mnt/etc/secrets/ssh_host_key
  chown root:root /mnt/etc/secrets/ssh_host_key
  chmod 600 /mnt/etc/secrets/ssh_host_key

  if [ "${cfg.encryptBoot}" = "true" || "${cfg.encryptRoot}" = "true" ]; then
    cp /tmp/keyfile0.bin /mnt/etc/secrets/keyfile0.bin
    chmod 000 /mnt/etc/secrets/keyfile*.bin
  fi

  if [ "${cfg.debug}" != "true" ]; then
    nixos-install --flake "${cfg.flakesPath}/#${cfg.hostname}" --root /mnt --no-root-passwd

    configPath="/mnt/persist/home/"${cfg.mainuser}"/nixos-config"
    if [ ! -d "$configPath" ]; then
      mkdir -p $configPath
      chown 1000:100 $configPath
    fi
    cp -aT ${cfg.flakesPath} $configPath
  fi

  if [ "${cfg.oldUefi}" = "true" ]; then
    mkdir -p /mnt/boot/efi/EFI/Microsoft/Boot
    cp /mnt/boot/efi/EFI/BOOT/BOOTX64.EFI /mnt/boot/efi/EFI/Microsoft/Boot/bootmgr.efi
    cp /mnt/boot/efi/EFI/BOOT/BOOTX64.EFI /mnt/boot/efi/EFI/Microsoft/Boot/bootmgfw.efi
  fi

  umount -Rl /mnt
  zpool export -a
  [ "${cfg.encryptBoot}" = "true" ] && cryptsetup luksClose ${cfg.cryptBoot}
  [ "${cfg.encryptRoot}" = "true" ] && cryptsetup luksClose ${cfg.cryptRoot}

  if [ "${cfg.autoReboot}" = "true" ]; then
    if ! systemctl reboot --firmware-setup ; then
      pprint "Reboot into efi firmware setup failed! Shutdown in 30 seconds"
      sleep 30
      systemctl poweroff
    fi
  fi
''