{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in {
  environment.sessionVariables = {
    XCURSOR_PATH = lib.mkForce "/home/alukard/.icons";
    XCURSOR_SIZE = lib.mkForce (toString thm.cursorSize);
  };

  home-manager.users.alukard = {
    xsession.pointerCursor = {
      package = thm.cursorPackage;
      name = "Bibata-Modern-Classic";
      size = thm.cursorSize;
    };

    home.file.".icons/default" = {
      source = "${thm.cursorPackage}/share/icons/Bibata-Modern-Classic";
    };
  };
}