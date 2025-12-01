{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOverride
    ;

  cfg = config.ataraxia.defaults.boot;
in
{
  options.ataraxia.defaults.boot = {
    enable = mkEnableOption "Default boot settings";
    cachyosKernel = mkEnableOption "Use cachyos kernel";
  };

  config = mkIf cfg.enable {
    # TODO: remove after nixos-25.11 release
    system.modulesTree = mkIf cfg.cachyosKernel [
      (lib.getOutput "modules" pkgs.linuxPackages_cachyos.kernel)
    ];

    boot = {
      loader = {
        efi.efiSysMountPoint = "/efi";
        efi.canTouchEfiVariables = mkDefault true;
        limine = {
          enable = mkDefault true;
          enableEditor = mkDefault false;
          maxGenerations = mkDefault 10;
          validateChecksums = mkDefault true;
          panicOnChecksumMismatch = mkDefault true;
          efiSupport = mkDefault true;
          efiInstallAsRemovable = mkDefault false;
          biosSupport = mkDefault false;
        };
        grub.enable = mkDefault false;
        systemd-boot.enable = mkDefault false;
        timeout = mkDefault 4;
      };

      kernelParams = [
        "kvm.ignore_msrs=1"
        "kvm.report_ignored_msrs=0"
        "nofb"
        "rd.systemd.show_status=auto"
        "rd.udev.log_priority=3"
        "zswap.enabled=0"
      ];

      kernelPackages = mkOverride 900 (
        if cfg.cachyosKernel then pkgs.linuxPackages_cachyos else pkgs.linuxPackages_xanmod_latest
      );
      zfs.package = mkOverride 900 (if cfg.cachyosKernel then pkgs.zfs_cachyos else pkgs.zfs_unstable);

      consoleLogLevel = 3;

      kernel.sysctl = mkIf config.zramSwap.enable {
        "vm.swappiness" = 100;
        "vm.vfs_cache_pressure" = 200;
        "vm.dirty_background_ratio" = 1;
        "vm.dirty_ratio" = 40;
        "vm.page-cluster" = 0;
      };

      tmp.cleanOnBoot = !config.boot.tmp.useTmpfs;
    };
  };
}
