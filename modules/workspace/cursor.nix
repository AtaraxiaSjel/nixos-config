{ pkgs, lib, ... }: {
  environment.sessionVariables = {
    XCURSOR_PATH = lib.mkForce "/home/alukard/.icons";
  };

  home-manager.users.alukard = {
    xsession.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
    };

    home.file.".icons/default" = {
      source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic";
    };
  };
}