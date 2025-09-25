{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.brave;
in
{
  options.ataraxia.programs.brave = {
    enable = mkEnableOption "Enable brave program";
  };

  config = mkIf cfg.enable {
    dbus.packages = [ config.programs.chromium.package ];

    programs.chromium = {
      enable = true;
      package = pkgs.brave;
    };

    persist.state.directories = [
      ".config/BraveSoftware/Brave-Browser"
    ];
  };
}
