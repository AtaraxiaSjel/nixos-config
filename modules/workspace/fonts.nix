{ pkgs, config, lib, ... }: {
  fonts = {
    fonts = with pkgs; [
      terminus_font
      opensans-ttf
      roboto
      roboto-mono
      roboto-slab
      # nerdfonts
      fira-code
      noto-fonts
      noto-fonts-emoji
      hasklig
      powerline-fonts
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
