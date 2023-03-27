{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in {
  environment.sessionVariables = {
    XCURSOR_PATH = lib.mkForce "/home/${config.mainuser}/.icons";
  };

  home-manager.users.${config.mainuser} = {
    home.pointerCursor = {
      package = thm.cursorPackage;
      name = "Bibata-Modern-TokyoNight";
      size = thm.cursorSize;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}