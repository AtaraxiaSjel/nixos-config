{ config, pkgs, lib, ... }:

with rec {
  inherit (config) device deviceSpecific;
};
with deviceSpecific; {
  services.tlp = {
    enable = isLaptop;
    extraConfig = ''
      # To avoid filesystem corruption on btrfs formatted partitions
      SATA_LINKPWR_ON_BAT=max_performance
      # Recommended
      CPU_SCALING_GOVERNOR_ON_AC=powersave
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
      CPU_HWP_ON_AC=balance_performance
      CPU_HWP_ON_BAT=balance_power
      CPU_BOOST_ON_AC=1
      CPU_BOOST_ON_BAT=0
      DISK_DEVICES="nvme0n1 sda"
      DISK_APM_LEVEL_ON_AC="255 254"
      DISK_APM_LEVEL_ON_BAT="128 128"
    '';
  };
  services.undervolt = {
    enable = (device == "Dell-Laptop");
    coreOffset = "-120";
    gpuOffset = "-54";
  };
}
