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
    '';
  };
  services.undervolt = {
    enable = (device == "Dell-Laptop");
    coreOffset = "-120";
    gpuOffset = "-54";
  }
}
