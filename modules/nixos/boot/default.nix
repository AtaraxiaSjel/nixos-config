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
    mkOption
    mkOverride
    types
    ;

  cfg = config.ataraxia.defaults.boot;

  cachyosKernel =
    if cfg.kernelLevel == "v3" then
      pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3
    else if cfg.kernelLevel == "v4" then
      pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v4
    else
      pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v2;
  cachyosPatched = cachyosKernel;

  # cachyosPatched = cachyosKernel.extend (
  #   lfinal: lprev: {
  #     kernel = lprev.kernel.overrideAttrs (oa: {
  #       patches = (oa.patches or [ ]) ++ [ ];
  #     });
  #     zfs_cachyos = lprev.zfs_cachyos.overrideAttrs (oa: {
  #       patches = (oa.patches or [ ]) ++ [
  #         (pkgs.fetchpatch2 {
  #           name = "zfs-fideduperange.patch";
  #           url = "https://github.com/openzfs/zfs/compare/master...Mic92:zfs:fideduperange.patch?full_index=1";
  #           hash = "sha256-WdbKVcSvdcvrkJv4gFhamvwwBjg9t4Kq3uFb0+28vgU=";
  #         })
  #       ];
  #     });
  #   }
  # );
in
{
  options.ataraxia.defaults.boot = {
    enable = mkEnableOption "Default boot settings";
    cachyosKernel = mkEnableOption "Use cachyos kernel";
    kernelLevel = mkOption {
      type = types.enum [
        "v2"
        "v3"
        "v4"
      ];
      default = "v3";
    };
  };

  config = mkIf cfg.enable {
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
        if cfg.cachyosKernel then cachyosPatched else pkgs.linuxPackages_xanmod_latest
      );
      zfs.package = mkOverride 900 (
        if cfg.cachyosKernel then config.boot.kernelPackages.zfs_cachyos else pkgs.zfs_unstable
      );

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
