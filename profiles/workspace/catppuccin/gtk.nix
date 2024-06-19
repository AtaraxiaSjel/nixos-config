{ cfg }: { config, pkgs, ... }: {
  home-manager.users.${config.mainuser} = rec {
    gtk = {
      enable = true;
      theme = {
        name = "Catppuccin-${cfg.flavorUpper}-${cfg.sizeUpper}-${cfg.accentUpper}-${cfg.gtkTheme}";
        package = pkgs.catppuccin-gtk.override {
          inherit (cfg) tweaks;
          accents = [ cfg.accent ];
          variant = cfg.flavor;
        };
      };
      cursorTheme = {
        name = "catppuccin-${cfg.flavor}-${cfg.accent}-cursors";
        package = pkgs.catppuccin-cursors.${cfg.flavor + cfg.accentUpper};
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
  };
}