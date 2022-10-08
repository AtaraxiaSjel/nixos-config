{ pkgs, config, lib, ... }:
let
  thm = config.lib.base16.theme;
in
{
  fonts = {
    fonts = with pkgs; [
      ibm-plex
#       ibm-plex-powerline
      fira-code
      roboto
      roboto-mono
      roboto-slab
      victor-mono
      # Icons
      font-awesome
      material-icons
    ];
    fontconfig = {
      enable = lib.mkForce true;
      defaultFonts = {
        monospace = [ "${thm.fonts.mono.family} ${thm.fontSizes.normal.str}" ];
        sansSerif = [ "${thm.fonts.main.family} ${thm.fontSizes.normal.str}" ];
        serif = [ "${thm.fonts.serif.family} ${thm.fontSizes.normal.str}" ];
      };
    };
    enableDefaultFonts = true;
  };
}
