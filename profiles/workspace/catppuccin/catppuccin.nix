{ cfg }: { config, pkgs, lib, inputs, ... }: {
  catppuccin.accent = cfg.accent;
  catppuccin.flavor = cfg.flavor;
  catppuccin.grub.enable = true;
  catppuccin.tty.enable = true;

  environment.systemPackages = [
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.libsForQt5.qt5ct
  ];

  home-manager.users.${config.mainuser} = {
    catppuccin.accent = cfg.accent;
    catppuccin.flavor = cfg.flavor;

    catppuccin.bat.enable = true;
    catppuccin.bottom.enable = true;
    catppuccin.fzf.enable = true;
    catppuccin.gitui.enable = true;
    catppuccin.glamour.enable = true;
    catppuccin.kitty.enable = true;
    catppuccin.kvantum.apply = true;
    catppuccin.kvantum.enable = true;
    catppuccin.mako.enable = true;
    catppuccin.micro.enable = true;
    catppuccin.mpv.enable = true;
    catppuccin.rofi.enable = true;
    catppuccin.waybar.enable = true;
    catppuccin.waybar.mode = "createLink";
    catppuccin.zathura.enable = true;
    catppuccin.zsh-syntax-highlighting.enable = true;
    programs.zsh.syntaxHighlighting.enable = true;

    catppuccin.vscode = {
      enable = true;
      flavor = cfg.flavor;
      settings = {
        accent = cfg.accent;
        boldKeywords = false;
        italicComments = false;
        italicKeywords = false;
        extraBordersEnabled = false;
        workbenchMode = "flat";
        bracketMode = "dimmed";
        colorOverrides = {
          ${cfg.flavor} = {
            base = "#1c1c2d";
            mantle = "#191925";
            crust = "#151511";
          };
        };
        customUIColors = {
          "statusBar.foreground" = "accent";
        };
      };
    };
    programs.vscode.profiles.default.userSettings = {
      "gopls.ui.semanticTokens" = lib.mkForce true;
      "editor.semanticHighlighting.enabled" = lib.mkForce true;
      "terminal.integrated.minimumContrastRatio" = lib.mkForce 1;
      "window.titleBarStyle" = lib.mkForce "custom";
      "workbench.colorTheme" = lib.mkForce "Catppuccin ${cfg.flavorUpper}";
      "workbench.iconTheme" = lib.mkForce "catppuccin-${cfg.flavor}";
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
