{
  config,
  lib,
  pkgs,
  inputs,
  useHomeManager,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.moon-crab;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  imports = [ inputs.moon-crab.nixosModules.default ];

  options.ataraxia.programs.moon-crab = {
    enable = mkEnableOption "Enable moon-crab steam";
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

    programs.moon-crab = {
      user = defaultUser;
      artitux = {
        enable = true;
        kmod.enable = true;
        kmod.autoload = true;
      };
      luatools.enable = true;
      slssteam.enable = true;
      slssteam.flavor = "moon";
      slssteam.settings = {
        DisableCloud = true;
      };
      steam = {
        enable = true;
        extraCompatPackages = builtins.attrValues {
          inherit (pkgs) proton-ge-bin proton-cachyos-bin-v3;
        };
        extraPackages = [ pkgs.libnotify ];
        protontricks.enable = true;
      };
    };

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        startupApplications = [
          "${config.programs.steam.package}/bin/steam"
          "/run/current-system/sw/bin/lumen"
        ];
        persist.state.directories = [
          ".config/SLSsteam"
          # ".config/Tachibana Labs"
          # ".local/share/ACCELA"
          ".local/share/Lumen"
          # ".local/share/SLSsteam"
          ".local/share/Steam"
        ];
      };
    };
  };
}
