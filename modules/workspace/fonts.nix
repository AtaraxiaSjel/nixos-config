{ pkgs, config, lib, ... }:
let
  thm = config.lib.base16.theme;
in
{
  fonts = {
    fonts = with pkgs; [
      ibm-plex
      ibm-plex-powerline
      fira-code
      material-design-icons
      material-icons
      roboto
      roboto-mono
      roboto-slab
      font-awesome_4
      # powerline-fonts
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "${thm.fontMono} 13" ];
        sansSerif = [ "${thm.font} 13" ];
        serif = [ "${thm.fontSerif} 13" ];
      };
    };
    enableDefaultFonts = true;
  };
}