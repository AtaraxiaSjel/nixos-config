{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in
{

  # Support Wal color theme
  home-manager.users.alukard.home.file.".cache/wal/colors".text = ''
    #${thm.base00-hex}
    #${thm.base01-hex}
    #${thm.base02-hex}
    #${thm.base03-hex}
    #${thm.base04-hex}
    #${thm.base05-hex}
    #${thm.base06-hex}
    #${thm.base07-hex}
    #${thm.base08-hex}
    #${thm.base09-hex}
    #${thm.base0A-hex}
    #${thm.base0B-hex}
    #${thm.base0C-hex}
    #${thm.base0D-hex}
    #${thm.base0E-hex}
    #${thm.base0F-hex}
  '';
}