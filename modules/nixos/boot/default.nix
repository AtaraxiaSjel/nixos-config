{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkEnableOption mkIf;

  cfg = config.ataraxia.defaults.boot;
in
{
  options.ataraxia.defaults.boot = {
    enable = mkEnableOption "Default boot settings";
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        timeout = mkDefault 4;
        systemd-boot.enable = mkDefault false;
      };

      kernelParams = [
        "kvm.ignore_msrs=1"
        "kvm.report_ignored_msrs=0"
        "nofb"
        "rd.systemd.show_status=auto"
        "rd.udev.log_priority=3"
        "zswap.enabled=0"
      ];

      kernelPackages = pkgs.linuxPackages_xanmod_latest;

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
