{ pkgs, config, lib, ... }: {
  fonts = {
    fonts = with pkgs; [
      # terminus_font
      # opensans-ttf
      roboto
      roboto-mono
      roboto-slab
      fira-code
      # noto-fonts
      # noto-fonts-emoji
      powerline-fonts
      material-icons
      font-awesome_4
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["Roboto Mono 13"];
        sansSerif = ["Roboto 13"];
        serif = ["Roboto Slab 13"];
      };
    };
    enableDefaultFonts = true;
  };
}
