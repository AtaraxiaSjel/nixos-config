{ inputs, config, pkgs, lib, ... }:
let
  zfs_arc_max = toString (2 * 1024 * 1024 * 1024);
  chaoticPkgs = inputs.chaotic.packages.${pkgs.hostPlatform.system};
in {
  boot = {
    kernelPackages = chaoticPkgs.linuxPackages_cachyos;
    zfs.package = chaoticPkgs.zfs_cachyos;

    initrd = {
      supportedFilesystems = [ "zfs" ];
      luks.devices = {
        "cryptroot" = {
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
          bypassWorkqueues = true;
        };
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/keyfile0.bin";
      };
    };

    loader = {
      grub = {
        enable = true;
        device = "nodev";
        copyKernels = true;
        efiSupport = true;
        enableCryptodisk = true;
        useOSProber = false;
        zfsSupport = true;
      };
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
      generationsDir.copyKernels = true;
    };

    kernelParams = [
      "zfs.metaslab_lba_weighting_enabled=0"
      "zfs.zfs_arc_max=${zfs_arc_max}"
    ];
    tmp.useTmpfs = true;
    tmp.tmpfsSize = "4G";
  };

  persist = {
    enable = true;
    cache.clean.enable = true;
  };

  fileSystems."/home".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.services.rollback = {
    description = "Rollback zfs to a pristine state on boot";
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-rpool.service" ];
    before = [ "sysroot.mount" ];
    path = [ config.boot.zfs.package ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r rpool/nixos/root@empty && echo "  >>> rollback root <<<"
      zfs rollback -r rpool/user/home@empty && echo "  >>> rollback home <<<"
    '';
  };
}
