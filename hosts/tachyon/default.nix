# tachyon — NanoPi R3S-LTS (RK3566), экспериментальный хост.
# Минимальный модуль: board-support из nixos-nanopi-r3s + disko с 16M
# зазором под Rockchip-загрузчик.
#
# Раскладка (и в disko ниже, и в заводском образе — менять только парой
# с дефолтами lib.mkImage: partStart/bootSizeMiB/bootLabel/partLabel):
#   зазор 0–16M: idbloader (32K) + u-boot.itb (8M)
#   p1 16M→528M, FAT32, disk-main-boot  → /boot (extlinux+ядро+initrd)
#   p2 остаток, btrfs, disk-main-root   → сабволюмы (см. disko ниже)
# Отдельный /boot обязателен: inindev u-boot читает ext4/FAT, но НЕ btrfs
# (проверено strings по u-boot.itb — ноль упоминаний), так что /boot как
# каталог на btrfs не загрузился бы: u-boot не нашёл бы extlinux.conf.
# Имена сабволюмов — как в hosts/redshift (rootfs/homefs/persist/nix),
# чтобы rollback-паттерн переносился 1:1; опции SD-настроены
# (compress=zstd,noatime,discard=async — без autodefrag/ssd от redshift,
# на флеше autodefrag лишь добавляет write amplification).
#
# Заводской образ — плоский btrfs-корень (сабволюмы офлайн создать
# нельзя: make-btrfs-fs не монтирует ФС), поэтому initrd при первой
# загрузке конвертирует его в сабволюм-раскладку disko и снимает
# read-only rootfs-blank; все следующие загрузки — откат rootfs к blank
# (erase-your-darlings, только rootfs; /nix живёт отдельно и переживает
# откат вместе с профилями). Живые переустановки (disko --mode /
# nixos-anywhere) получают те же сабволюмы+blank'и штатно через disko
# (subvolumes + postCreateHook) — initrd-миграция тогда no-op.
#
# Что берём из board-репо (и только это):
# - nixosModules.r3s-lts: DTB, консоль ttyS2, initrd-модули, firmware,
#   переименование NIC wan0/lan0 (см. PLAN-R3S.md, commands-logs.txt).
# - nixosModules.register-nix-paths: first-boot регистрация store для
#   ЗАВОДСКОГО образа (не nixos-install). FS-agnostic; на живых системах
#   no-op (ConditionPathExists=/nix-path-registration). Идемпотентен,
#   поэтому переживает и initrd-миграцию, и откаты rootfs к blank
#   (blank содержит файл регистрации, сервис отрабатывает заново).
# modules/image.nix и boot.nix из board-репо НЕ импортим: там жёстко
# ext4 + resize2fs, нам нужен btrfs сразу.
#
# Заводской образ собирается НЕ disko imageBuilder (его VM-флоу несовместим
# с lite-config: явный _module.args.pkgs гасит hostPlatform-форсинг
# systemToInstallNative, в x86_64 VM едут aarch64-тулзы), а board-функцией
# lib.mkImage (FAT через mkdosfs+mtools, btrfs через make-btrfs-fs, sfdisk
# GPT + dd загрузчика, без VM):
#   nix build --impure --expr '
#     let cfg = builtins.getFlake "/home/ataraxia/nixos-config";
#     in cfg.inputs.nixos-nanopi-r3s.lib.mkImage {
#       pkgs = cfg.inputs.nixpkgs.legacyPackages.x86_64-linux;
#       model = "r3s-lts";
#       system = cfg.nixosConfigurations.tachyon;
#       fs = "btrfs"; imageName = "tachyon";
#     }'
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./incus.nix
    ./kernel.nix
    ./minimal.nix
    inputs.nixos-nanopi-r3s.nixosModules.r3s-lts
    inputs.nixos-nanopi-r3s.nixosModules.register-nix-paths
    inputs.disko.nixosModules.disko

    inputs.srvos.nixosModules.common
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
  ];

  # Не включаем ataraxia-роль server/base: base тянет
  # ataraxia.defaults.boot (limine + xanmod под x86) и hardware-микрокод,
  # что противоречит extlinux + дефолтному aarch64-ядру платы.
  ataraxia.defaults.role = "none";
  # === roles ===
  ataraxia.profiles.hardened = true;
  ataraxia.profiles.minimal = true;
  fonts.enableDefaultPackages = false;
  fonts.fontconfig.enable = false;
  nix.optimise.automatic = false;
  persist.enable = true;
  time.timeZone = "Etc/UTC";
  zramSwap.enable = true;
  services.speechd.enable = false;
  services.userborn.enable = true;
  ataraxia.defaults.run0.enable = true;
  ataraxia.defaults.ssh.enable = true;

  srvos.registerSelf = false;
  srvos.update-diff.enable = false;
  environment = {
    systemPackages = [ pkgs.micro ];
    variables.EDITOR = lib.getExe pkgs.micro;
  };
  # === end roles ===

  # Board уже переименовал NIC в wan0/lan0 через systemd.link.
  # Минимум для первого бута: DHCP на обоих, дальше настроишь сам.
  systemd.network.enable = true;
  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.firewall.enable = true;
  systemd.network.networks = {
    "10-wan" = {
      matchConfig.Name = "wan0";
      networkConfig.DHCP = "yes";
    };
    "20-lan" = {
      matchConfig.Name = "lan0";
      networkConfig.DHCP = "yes";
    };
  };

  # --- Диск: GPT с зазором 16M под Rockchip-загрузчик ---
  # SPL грузится с фиксированных LBA (idbloader ~32K, u-boot ~8M),
  # поэтому первый раздел стартует с 16M.
  # p1 FAT32 /boot — u-boot не читает btrfs, extlinux+ядро+initrd только тут.
  # p2 btrfs — сабволюмы в стиле hosts/redshift (имена 1:1, опции под SD).
  # ВАЖНО: label заданы явно. Дефолт disko — "<type>-<disk>-<раздел>"
  # (здесь вышло бы gpt-main-root), а mkImage и initrd ждут disk-main-*.
  # Эта декларация — для живой системы (fileSystems) и живых
  # переустановок (disko --mode / nixos-anywhere): зазор 0–16M вне
  # разделов, загрузчик их переживает. Заводской образ собирается
  # board-функцией lib.mkImage с той же геометрией (см. шапку файла).
  # disko.imageBuilder здесь намеренно НЕТ: его VM-флоу несовместим
  # с lite-config (см. шапку), фабрика — только через mkImage.
  disko.devices.disk.main =
    let
      # SD-опции: как redshift, но без autodefrag (лишняя запись на флеш)
      # и ssd (на SD автораспознаётся); discard=async обязателен для флеша.
      sdMountOpts = [
        "compress=zstd"
        "noatime"
        "discard=async"
      ];
    in
    {
      type = "disk";
      # На этой плате SD видна как mmcblk1 (см. commands-logs.txt);
      # важно для disko --mode destroy,format,mount / nixos-anywhere.
      device = "/dev/mmcblk1";
      imageSize = "4G";
      imageName = "tachyon";
      content = {
        type = "gpt";
        partitions.boot = {
          label = "disk-main-boot";
          start = "16M";
          size = "512M";
          type = "0700";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        partitions.root = {
          label = "disk-main-root";
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            # Живые установки: blank-эталоны сразу, как в redshift.
            # /nix отдельным blank'ом не покрываем — он переживает откаты.
            postCreateHook = ''
              mount -t btrfs /dev/disk/by-partlabel/disk-main-root /mnt
              btrfs subvolume snapshot -r /mnt/rootfs /mnt/snapshots/rootfs-blank
              btrfs subvolume snapshot -r /mnt/homefs /mnt/snapshots/homefs-blank
              umount /mnt
            '';
            subvolumes = {
              "/snapshots" = { };
              "/rootfs" = {
                mountpoint = "/";
                mountOptions = sdMountOpts;
              };
              "/homefs" = {
                mountpoint = "/home";
                mountOptions = sdMountOpts;
              };
              "/persist" = { };
              "/persist/nix" = {
                mountpoint = "/nix";
                mountOptions = sdMountOpts;
              };
              "/persist/impermanence" = {
                mountpoint = "/persist";
                mountOptions = sdMountOpts;
              };
              # Workload state must survive rootfs rollbacks: dedicated
              # top-level subvolume (sibling of rootfs, never snapshotted
              # for blank, never rolled back). Snapshots/send-receive for
              # backups are an operational layer on top, not disko.
              "/incus" = {
                mountpoint = "/var/lib/incus";
                mountOptions = sdMountOpts;
              };
            };
          };
        };
      };
    };

  # --- Factory image: repair /nix top-level ownership (S0 finding) --------
  # mkImage populates the btrfs image as the build user, so /nix ships
  # owned by UID 1000. systemd-tmpfiles then refuses EVERY rule under /nix
  # ("unsafe path transition" guard) -> /nix/var/nix/daemon-socket is never
  # created -> nix-daemon.socket stays dead (ConditionPathIsReadWrite
  # unmet), and the gcroots current-system/booted-system links are missing.
  # A nixos-install never hits this (root-owned /nix from the start).
  # Idempotent one-shot before tmpfiles-setup: no-op on healthy systems,
  # self-heals factory images on first (and every) boot. Non-recursive on
  # purpose: everything below /nix is already root-owned.
  systemd.services.nix-store-ownership = {
    description = "Repair /nix top-level ownership from factory images";
    wantedBy = [ "sysinit.target" ];
    before = [ "systemd-tmpfiles-setup.service" ];
    # DefaultDependencies MUST stay off: the implicit After=basic.target
    # closes an ordering cycle (tmpfiles-setup -> this unit -> basic ->
    # sockets -> nix-daemon.socket -> tmpfiles-setup) and systemd deletes
    # tmpfiles-setup's start job to break it — silently skipping ALL
    # tmpfiles rules (/var/empty, /var/run, daemon-socket). Seen live in
    # the S1 slot: sshd+nscd dead on the affected boots. after=local-fs
    # instead: guarantees /nix is mounted, cannot cycle (local-fs has no
    # path back into sysinit).
    unitConfig.DefaultDependencies = false;
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/chown 0:0 /nix";
    };
  };

  # --- Switch-safety: re-run userborn in activation (S1 finding) -----------
  # userborn owns ALL users (sysusers is disabled) and runs as a boot-only
  # service. Switching generations remounts /etc (overlay, fresh empty
  # upper): the new tree has no passwd/group/shadow until userborn re-runs,
  # and switch restarts only CHANGED units — so without this, every switch
  # kills SSH (sshd user gone) until the next reboot. Seen live in S1.
  # (Referencing the toplevel in restartTriggers would recurse; activation
  # is the correct hook — it runs on every switch, after the etc remount.)
  # The re-run is idempotent (userborn already runs at every boot, right
  # after this activation). Persist bind-mounts (machine-id) need no help:
  # the etc snippet re-binds /etc submounts into the new tree itself.
  system.activationScripts.userborn-resync = {
    deps = [ "etc" ];
    text = ''
      ${config.systemd.services.userborn.serviceConfig.ExecStart}
    '';
  };

  # NOTE: subuid/subgid real files (newuidmap needs O_NOFOLLOW-safe regular
  # files) are written by incus.nix's subuid-materialize activation, not via
  # environment.etc (that would only produce store symlinks).

  # --- First-boot: плоский заводской btrfs → сабволюмы + откат rootfs ---
  # Заводской образ плоский (сабволюмы офлайн не создать), а fileSystems
  # выше монтируют subvol=/rootfs — без конвертации первая загрузка
  # упала бы. Конвертация — отдельным initrd-юнитом ПЕРЕД sysroot.mount
  # (в systemd stage-1, а он здесь дефолт, postDeviceCommands запрещён
  # ассёртом — только services, паттерн erase-модуля filesystems/btrfs).
  # Раз: если /rootfs нет — создаём раскладку снапшотом плоского top'а
  # (стор переезжает COW-разделяемо за O(1), копирования нет) и снимаем
  # read-only rootfs-blank. Два: если раскладка есть — откатываем
  # rootfs к blank (erase-your-darlings, только rootfs; /nix живёт отдельно
  # и переживает откат вместе с профилями). Живые disko-установки получают
  # сабволюмы+blank'и штатно через disko — первая ветка тогда no-op.
  # Принцип для роутера — деградация вместо падения: нет blank'а,
  # грузимся как есть, с предупреждением в журнал.
  boot.initrd.systemd.services.tachyon-btrfs-layout = {
    description = "Convert flat factory btrfs to subvolume layout, roll back rootfs to blank";
    wantedBy = [ "initrd.target" ];
    # Ждать девайс явно: иначе гонка с udev (by-partlabel ещё нет).
    # Имя — systemd-escape -p /dev/disk/by-partlabel/disk-main-root.
    requires = [ ''dev-disk-by\x2dpartlabel-disk\x2dmain\x2droot.device'' ];
    after = [ ''dev-disk-by\x2dpartlabel-disk\x2dmain\x2droot.device'' ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    path = with pkgs; [
      btrfs-progs
      coreutils
      util-linux
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      tachyonRootDev=/dev/disk/by-partlabel/disk-main-root
      mkdir -p /mnt-tachyon-mig
      mount -t btrfs -o subvolid=5 "$tachyonRootDev" /mnt-tachyon-mig
      if [ ! -e /mnt-tachyon-mig/rootfs ]; then
        echo "tachyon: flat factory root detected, creating subvolume layout..."
        # Снапшотим весь плоский top (стор включается COW-разделяемо за
        # O(1)) и ПЛЮЩИМ содержимое: поднимаем всё из S/nix/ в сам S, затем
        # переименовываем S в /persist/nix. Все три операции — rename внутри
        # одного сабволюма / переименование сабволюма: O(1), новых инодов
        # почти нет. Кросс-сабволюмные перемещения НЕЛЬЗЯ: btrfs отдаёт
        # EXDEV, mv тихо падает в рекурсивное копирование (в QEMU доказано:
        # mv nix-new/nix persist/nix → ENOSPC на метаданных, как и
        # cp --reflink: ~500k новых инодов заводской ФС не тянет).
        btrfs subvolume snapshot /mnt-tachyon-mig /mnt-tachyon-mig/nix-new
        rm /mnt-tachyon-mig/nix-new/nix-path-registration /mnt-tachyon-mig/nix-new/README.factory-image.txt
        shopt -s dotglob
        if [ -n "$(ls -A /mnt-tachyon-mig/nix-new/nix)" ]; then
          mv /mnt-tachyon-mig/nix-new/nix/* /mnt-tachyon-mig/nix-new/
        fi
        shopt -u dotglob
        rmdir /mnt-tachyon-mig/nix-new/nix
        btrfs subvolume create /mnt-tachyon-mig/rootfs
        btrfs subvolume create /mnt-tachyon-mig/homefs
        btrfs subvolume create /mnt-tachyon-mig/persist
        btrfs subvolume create /mnt-tachyon-mig/persist/impermanence
        btrfs subvolume create /mnt-tachyon-mig/snapshots
        mv /mnt-tachyon-mig/nix-new /mnt-tachyon-mig/persist/nix
        mv /mnt-tachyon-mig/nix-path-registration /mnt-tachyon-mig/rootfs/nix-path-registration
        mkdir -p /mnt-tachyon-mig/rootfs/boot /mnt-tachyon-mig/rootfs/home /mnt-tachyon-mig/rootfs/nix /mnt-tachyon-mig/rootfs/persist /mnt-tachyon-mig/rootfs/snapshots /mnt-tachyon-mig/rootfs/srv /mnt-tachyon-mig/rootfs/etc /mnt-tachyon-mig/rootfs/var/log /mnt-tachyon-mig/rootfs/var/lib/incus /mnt-tachyon-mig/rootfs/tmp /mnt-tachyon-mig/rootfs/root /mnt-tachyon-mig/rootfs/mnt /mnt-tachyon-mig/rootfs/media
        chmod 1777 /mnt-tachyon-mig/rootfs/tmp
        chmod 700 /mnt-tachyon-mig/rootfs/root
        btrfs subvolume snapshot -r /mnt-tachyon-mig/rootfs /mnt-tachyon-mig/snapshots/rootfs-blank
        rm -rf /mnt-tachyon-mig/nix /mnt-tachyon-mig/README.factory-image.txt
        echo "tachyon: subvolume layout ready"
      elif [ -e /mnt-tachyon-mig/snapshots/rootfs-blank ]; then
        echo "tachyon: rolling rootfs back to blank snapshot..."
        btrfs subvolume list -o /mnt-tachyon-mig/rootfs | cut -f9 -d' ' | while read -r subvolume; do
          btrfs subvolume delete "/mnt-tachyon-mig/$subvolume"
        done || true
        btrfs subvolume delete /mnt-tachyon-mig/rootfs
        btrfs subvolume snapshot /mnt-tachyon-mig/snapshots/rootfs-blank /mnt-tachyon-mig/rootfs
      else
        echo "tachyon: WARNING: no rootfs-blank snapshot, booting rootfs as-is"
      fi
      # Idempotent for all three cases above (flat, rolled-back,
      # already-converted): disks converted before the incus subvolume
      # existed must gain it, or the /var/lib/incus mount fails the boot.
      if [ ! -e /mnt-tachyon-mig/incus ]; then
        echo "tachyon: creating missing incus subvolume..."
        btrfs subvolume create /mnt-tachyon-mig/incus
      fi
      umount /mnt-tachyon-mig
    '';
  };

  # --- Минимум записей на SD ---
  fileSystems."/var/log" = {
    fsType = "tmpfs";
    options = [
      "nodev"
      "nosuid"
      "mode=0755"
    ];
  };
  boot.tmp.useTmpfs = true;
  services.journald.storage = "volatile";
  services.journald.extraConfig = ''
    SystemMaxUse=8M
    Compress=yes
  '';
  services.logrotate.enable = lib.mkForce false;

  users.users.root.initialHashedPassword = "$y$j9T$jpOuNmz7hPJPWPyT05FAZ/$0iFlDbkW4IetmbTWkq0/cdnXkQ.JDBDZgzz52sueLt3";
  services.openssh.enable = true;

  system.stateVersion = "26.05";
}
