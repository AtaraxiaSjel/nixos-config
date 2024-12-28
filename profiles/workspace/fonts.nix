{ pkgs, config, lib, ... }:
let
  thm = config.lib.base16.theme;
in
{
  fonts = {
    packages = with pkgs; [
      ibm-plex
      nerd-fonts.fira-code
      nerd-fonts.victor-mono
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
    enableDefaultPackages = true;
    fontDir.enable = true;
  };
}
