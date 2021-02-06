{ config, lib, pkgs, ... }: {

  home-manager.users.alukard = {
    xdg.configFile."spicetify/Themes/base16/color.ini".source = ./color.ini;
    xdg.configFile."spicetify/Themes/base16/user.css".source = ./user.css;
  };
}
