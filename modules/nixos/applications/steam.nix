{
  config,
  lib,
  pkgs,
  useHomeManager,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.steam;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.programs.steam = {
    enable = mkEnableOption "Enable steam";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "ntsync" ];
    programs.gamemode.enable = true;
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

    programs.steam = {
      enable = true;
      extest.enable = true;
      extraCompatPackages = builtins.attrValues {
        inherit (pkgs) proton-ge-bin proton-cachyos-bin-v3;
      };
      extraPackages = with pkgs; [
        libnotify
      ];
      protontricks.enable = true;
    };

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        startupApplications = [ "${config.programs.steam.package}/bin/steam" ];
        persist.state.directories = [ ".local/share/Steam" ];
      };
    };
  };
}
