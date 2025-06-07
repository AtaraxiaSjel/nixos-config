{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) hasAttr;
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

    home-manager = mkIf (hasAttr "users" config.home-manager) {
      users.${defaultUser} = {
        startupApplications = [ "${pkgs.corectrl}/bin/corectrl" ];
        persist.state.directories = [ ".config/corectrl" ];
      };
    };
  };
}
