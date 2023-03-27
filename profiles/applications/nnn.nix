{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    programs.nnn = {
      enable = true;
      package = pkgs.nnn.override { withNerdIcons = true; };
      # extraPackages = with pkgs; [ ffmpegthumbnailer mediainfo sxiv ];
      # bookmarks = {
      #   d = "~/Documents";
      #   D = "~/Downloads";
      #   p = "~/Pictures";
      #   v = "~/Videos";
      # };
      # plugins = { };
    };

    programs.zsh.shellAliases = {
      "n" = "nnn -deE";
    };
  };

  persist.state.homeDirectories = [
    ".config/nnn"
  ];
}