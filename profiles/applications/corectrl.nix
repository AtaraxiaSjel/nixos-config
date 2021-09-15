{ pkgs, lib, config, ... }:
with config.deviceSpecific; {
  config = lib.mkIf (devInfo.gpu.vendor == "amd") {
    programs.corectrl.enable =  true;
    startupApplications = [ "${pkgs.corectrl}/bin/corectrl" ];
  };
}
