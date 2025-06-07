{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (builtins) hasAttr;
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.steam;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.programs.steam = {
    enable = mkEnableOption "Enable steam";
  };

  config = mkIf cfg.enable {
    programs.gamescope.enable = true;
    programs.gamescope.capSysNice = false;

    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-cpp;
      extraRules = [
        {
          "name" = "gamescope";
          "nice" = -20;
        }
      ];
    };

    programs.steam.enable = true;
    programs.steam.extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    programs.steam.gamescopeSession.enable = true;
    programs.steam.gamescopeSession.env = {
      MANGOHUD = "1";
      CONNECTOR = "*,DP-3";
    };
    programs.steam.gamescopeSession.args = [ "--adaptive-sync" ];

    home-manager = mkIf (hasAttr "home-manager" options) {
      users.${defaultUser} = {
        startupApplications = [ "${config.programs.steam.package}/bin/steam" ];
        persist.state.directories = [ ".local/share/Steam" ];
      };
    };
  };
}
