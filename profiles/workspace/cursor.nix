{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in {
  home-manager.users.${config.mainuser} = {
    home.pointerCursor = {
      package = thm.cursorPackage;
      name = "Bibata-Modern-TokyoNight";
      size = thm.cursorSize;
      gtk.enable = true;
      x11.enable = true;
    };
    # home.file.".icons/default" = {
    #   source = "${thm.cursorPackage}/share/icons/Bibata-Modern-TokyoNight";
    # };
  };
}