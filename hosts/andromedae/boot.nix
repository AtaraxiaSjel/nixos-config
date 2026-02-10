{ lib, pkgs, ... }:
{
  ataraxia.defaults.boot.cachyosKernel = true;

  services.scx.enable = true;
  services.scx.scheduler = "scx_rustland";

  boot = {
    extraModulePackages = [ pkgs.rtl8761b-firmware ];

    kernelParams = [
      "pti=off"
      "retbleed=off" # big performance impact
      "spectre_v2=off"
    ];

    kernel.sysctl = {
      "kernel.split_lock_mitigate" = 0;
    };

    tmp.useTmpfs = true;
    tmp.tmpfsSize = "100%";
    tmp.tmpfsHugeMemoryPages = "within_size";

    supportedFilesystems = [ "ntfs" ];
  };

  fileSystems."/" = lib.mkForce {
    device = "none";
    options = [
      "defaults"
      "size=4G"
      "mode=755"
    ];
    fsType = "tmpfs";
  };

  # AMD EPP P-State management
  # powerManagement.cpuFreqGovernor = "powersave";
  # services.auto-epp = {
  #   enable = true;
  #   settings.Settings.epp_state_for_BAT = "balance_performance";
  #   settings.Settings.epp_state_for_AC = "balance_performance";
  # };
}
