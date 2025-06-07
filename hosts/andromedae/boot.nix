{ lib, pkgs, ... }:
{
  fileSystems."/" = lib.mkForce {
    device = "none";
    options = [
      "defaults"
      "size=4G"
      "mode=755"
    ];
    fsType = "tmpfs";
  };

  # initrd = {
  #   supportedFilesystems = [ "zfs" ];
  #   luks.devices = {
  #     "cryptroot" = {
  #       keyFile = "/keyfile0.bin";
  #       allowDiscards = true;
  #       bypassWorkqueues = true;
  #     };
  #   };
  #   secrets = {
  #     "keyfile0.bin" = "/etc/secrets/keyfile0.bin";
  #   };
  # };

  boot = {
    zfs.package = pkgs.zfs_unstable;

    loader = {
      grub = {
        enable = true;
        device = "nodev";
        copyKernels = true;
        efiSupport = true;
        enableCryptodisk = true;
        useOSProber = false;
        zfsSupport = true;
        gfxmodeEfi = "2560x1440";
      };
      efi.efiSysMountPoint = "/efi";
      efi.canTouchEfiVariables = true;
    };

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

  # AMD EPP P-State management
  # powerManagement.cpuFreqGovernor = "powersave";
  # services.auto-epp = {
  #   enable = true;
  #   settings.Settings.epp_state_for_BAT = "balance_performance";
  #   settings.Settings.epp_state_for_AC = "balance_performance";
  # };
}
