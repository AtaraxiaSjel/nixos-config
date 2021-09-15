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
      roboto
      roboto-mono
      roboto-slab
      # Icons
      font-awesome
      material-icons
    ];
    fontconfig = {
      enable = lib.mkForce true;
      defaultFonts = {
        monospace = [ "${thm.fontMono} ${thm.normalFontSize}" ];
        sansSerif = [ "${thm.font} ${thm.normalFontSize}" ];
        serif = [ "${thm.fontSerif} ${thm.normalFontSize}" ];
      };
    };
    enableDefaultFonts = true;
  };
}