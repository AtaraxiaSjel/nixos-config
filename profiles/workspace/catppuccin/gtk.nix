{ cfg }: { config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = rec {
    gtk = {
      enable = true;
      theme = let
        gtkTweaks = lib.concatStringsSep "," cfg.tweaks;
      in {
        name = "catppuccin-${cfg.flavor}-${cfg.accent}-${cfg.size}+${gtkTweaks}";
        package = pkgs.catppuccin-gtk.override {
          inherit (cfg) tweaks;
          accents = [ cfg.accent ];
          variant = cfg.flavor;
        };
      };
      iconTheme = {
        name = "Papirus-${cfg.gtkTheme}";
        package = pkgs.catppuccin-papirus-folders.override { inherit (cfg) accent flavor; };
      };
      font = {
        name = cfg.thm.fonts.main.family;
        size = cfg.thm.fontSizes.normal.int;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
    home.sessionVariables.GTK_THEME = gtk.theme.name;
    xdg.configFile = let
      gtk4Dir = "${gtk.theme.package}/share/themes/${gtk.theme.name}/gtk-4.0";
    in {
      "gtk-4.0/assets".source = "${gtk4Dir}/assets";
      "gtk-4.0/gtk.css".source = "${gtk4Dir}/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${gtk4Dir}/gtk-dark.css";
    };
  };
}