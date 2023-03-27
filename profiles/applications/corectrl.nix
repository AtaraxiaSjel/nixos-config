{ pkgs, lib, config, ... }:
with config.deviceSpecific; {
  config = lib.mkIf (devInfo.gpu.vendor == "amd") {
    programs.corectrl = {
      enable = true;
      gpuOverclock.enable = true;
      gpuOverclock.ppfeaturemask = "0xffffffff";
    };

    startupApplications = [ "${pkgs.corectrl}/bin/corectrl" ];

    persist.state.homeDirectories = [
      ".config/corectrl"
    ];
  };
}
