{
  config,
  lib,
  options,
  ...
}:
let
  inherit (builtins) hasAttr;
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.wayland;

  defaultUser = config.ataraxia.defaults.users.defaultUser;
  session = {
    command = "${getExe config.programs.uwsm.package} start hyprland-uwsm.desktop";
    user = defaultUser;
  };
in
{
  options.ataraxia.wayland = {
    enable = mkEnableOption "Enable wayland with compositor and other components";
    hyprland.enable = mkEnableOption "Enable hyprland compositor";
  };

  config = mkIf cfg.enable {
    programs.hyprland = mkIf cfg.hyprland.enable {
      enable = true;
      withUWSM = true;
    };

    services.greetd = {
      enable = true;
      settings = {
        terminal.vt = 1;
        default_session = session;
        initial_session = session;
      };
    };

    home-manager = mkIf (hasAttr "home-manager" options) {
      users.${defaultUser} = {
        ataraxia.wayland.hyprland.enable = cfg.hyprland.enable;
      };
    };
  };
}
