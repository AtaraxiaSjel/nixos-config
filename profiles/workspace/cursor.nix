{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
  profileDir = config.home-manager.users.alukard.home.profileDirectory;
in {
  environment.sessionVariables = {
    XCURSOR_PATH = lib.mkForce "${profileDir}/share/icons";
  };
  home-manager.users.alukard = {
    home.pointerCursor = {
      package = thm.cursorPackage;
      name = "Bibata-Modern-Classic";
      size = thm.cursorSize;
      gtk.enable = true;
      # x11.enable = true;
    };
    # home.file.".icons/default" = {
    #   source = "${thm.cursorPackage}/share/icons/Bibata-Modern-Classic";
    # };
  };
}