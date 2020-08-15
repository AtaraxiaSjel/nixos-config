
{ config, lib, pkgs, ... }:
{
  home-manager.users.alukard = {
    xresources.properties = with config.lib.base16.theme; {
      "*foreground" = "#${base05-hex}";
      "*background" = "#${base00-hex}";
      "*cursorColor" = "#${base05-hex}";
      "*color0" = "#${base00-hex}";
      "*color1" = "#${base08-hex}";
      "*color2" = "#${base0B-hex}";
      "*color3" = "#${base0A-hex}";
      "*color4" = "#${base0D-hex}";
      "*color5" = "#${base0E-hex}";
      "*color6" = "#${base0C-hex}";
      "*color7" = "#${base05-hex}";
      "*color8" = "#${base03-hex}";
      "*color9" = "#${base09-hex}";
      "*color10" = "#${base01-hex}";
      "*color11" = "#${base02-hex}";
      "*color12" = "#${base04-hex}";
      "*color13" = "#${base06-hex}";
      "*color14" = "#${base0F-hex}";
      "*color15" = "#${base07-hex}";
    };
  };
}