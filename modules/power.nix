{ config, pkgs, lib, ... }:

with rec {
  inherit (config) device deviceSpecific;
};
with deviceSpecific; {
  services.tlp = {
    enable = isLaptop;
    extraConfig = ''
      # Recommended
      CPU_SCALING_GOVERNOR_ON_AC=powersave
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
      CPU_HWP_ON_AC=balance_performance
      CPU_HWP_ON_BAT=balance_power
      CPU_BOOST_ON_AC=1
      CPU_BOOST_ON_BAT=0
      SCHED_POWERSAVE_ON_AC=0
      SCHED_POWERSAVE_ON_BAT=1
      CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
      CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
      DISK_DEVICES="nvme0n1 sda"
      DISK_APM_LEVEL_ON_AC="255 254"
      DISK_APM_LEVEL_ON_BAT="255 254"
      # To avoid filesystem corruption on btrfs formatted partitions
      SATA_LINKPWR_ON_BAT="med_power_with_dipm max_performance"
      SATA_LINKPWR_ON_AC="med_power_with_dipm max_performance"
    '';
    # TLP >1.3
    # tlp1_3 = ''
    #   # instead CPU_ENERGY_PERF_POLICY_ON_*
    #   CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
    #   CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
    # '';

  };
  services.undervolt = {
    enable = (device == "Dell-Laptop");
    coreOffset = "-120";
    gpuOffset = "-54";
  };
}
