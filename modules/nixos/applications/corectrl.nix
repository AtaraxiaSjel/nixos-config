{
  config,
  lib,
  pkgs,
  useHomeManager,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.corectrl;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.programs.corectrl = {
    enable = mkEnableOption "Enable corectrl program";
  };

  config = mkIf cfg.enable {
    programs.corectrl = {
      enable = true;
      gpuOverclock.enable = true;
      # gpuOverclock.ppfeaturemask = "0xffffffff";
    };

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        startupApplications = [ "${pkgs.corectrl}/bin/corectrl" ];
        persist.state.directories = [ ".config/corectrl" ];
      };
    };
  };
}
