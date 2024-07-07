{ cfg }: { config, pkgs, lib, inputs, ... }: {
  catppuccin.accent = cfg.accent;
  catppuccin.flavor = cfg.flavor;
  boot.loader.grub.catppuccin.enable = true;
  console.catppuccin.enable = true;

  environment.systemPackages = [
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.libsForQt5.qt5ct
  ];

  home-manager.users.${config.mainuser} = {
    catppuccin.accent = cfg.accent;
    catppuccin.flavor = cfg.flavor;

    qt.style.catppuccin.enable = true;
    qt.style.catppuccin.apply = true;
    services.mako.catppuccin.enable = true;
    programs = {
      bat.catppuccin.enable = true;
      bottom.catppuccin.enable = true;
      fzf.catppuccin.enable = true;
      gitui.catppuccin.enable = true;
      glamour.catppuccin.enable = true;
      kitty.catppuccin.enable = true;
      micro.catppuccin.enable = true;
      mpv.catppuccin.enable = true;
      rofi.catppuccin.enable = true;
      zathura.catppuccin.enable = true;
      zsh.syntaxHighlighting.enable = true;
      zsh.syntaxHighlighting.catppuccin.enable = true;
      waybar.catppuccin.enable = true;
      waybar.catppuccin.mode = "createLink";
    };

    wayland.windowManager.hyprland.extraConfig = ''
      exec=hyprctl setcursor catppuccin-${cfg.flavor}-${cfg.accent}-cursors ${toString cfg.thm.cursorSize}
    '';

    xdg.configFile = {
      qt5ct = {
        target = "qt5ct/qt5ct.conf";
        text = lib.generators.toINI { } {
          Appearance = {
            icon_theme = "Papirus-${cfg.gtkTheme}";
          };
        };
      };
      qt6ct = {
        target = "qt6ct/qt6ct.conf";
        text = lib.generators.toINI { } {
          Appearance = {
            icon_theme = "Papirus-${cfg.gtkTheme}";
          };
        };
      };
    };
  };

  themes.base16.extraParams = {
    iconTheme = lib.mkForce "Papirus-${cfg.gtkTheme}";
    iconPackage = lib.mkForce (pkgs.catppuccin-papirus-folders.override { inherit (cfg) accent flavor; });
    cursorPackage = lib.mkForce (pkgs.catppuccin-cursors.${cfg.flavor + cfg.accentUpper});
    cursorTheme = lib.mkForce "catppuccin-${cfg.flavor}-${cfg.accent}-cursors";
    cursorSize = lib.mkForce 32;
  };
}
