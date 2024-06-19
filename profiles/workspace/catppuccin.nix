{ config, pkgs, lib, inputs, ... }:
let
  thm = config.lib.base16.theme;
  # this capitalizes the first letter in a string.
  mkUpper =
    str:
    (lib.toUpper (builtins.substring 0 1 str)) +
    (builtins.substring 1 (builtins.stringLength str) str);

  accent = config.home-manager.users.${config.mainuser}.catppuccin.accent;
  flavor = config.home-manager.users.${config.mainuser}.catppuccin.flavor;
  size = "standard"; # "standard" "compact"
  tweaks = [ "normal" ]; # "black" "rimless" "normal"
  flavorUpper = mkUpper flavor;
  accentUpper = mkUpper accent;
  sizeUpper = mkUpper size;
  gtkTheme = if flavor == "latte" then "Light" else "Dark";
in
{
  home-manager.users.${config.mainuser} = rec {
    imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];
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

      vscode = {
        extensions = let
          ext-vscode = inputs.nix-vscode-marketplace.extensions.${pkgs.system}.vscode-marketplace;
        in [
          ext-vscode.alexdauenhauer.catppuccin-noctis
          ext-vscode.catppuccin.catppuccin-vsc-icons
          (inputs.catppuccin-vsc.packages.${pkgs.system}.catppuccin-vsc.override {
            accent = accent;
            boldKeywords = false;
            italicComments = false;
            italicKeywords = false;
            extraBordersEnabled = false;
            workbenchMode = "flat";
            bracketMode = "dimmed";
            colorOverrides = {
              mocha = {
                base = "#1c1c2d";
                mantle = "#191925";
                crust = "#151511";
              };
            };
            customUIColors = {
              "statusBar.foreground" = "accent";
            };
          })
        ];
        userSettings = {
          "gopls.ui.semanticTokens" = lib.mkForce true;
          "editor.semanticHighlighting.enabled" = lib.mkForce true;
          "terminal.integrated.minimumContrastRatio" = lib.mkForce 1;
          "window.titleBarStyle" = lib.mkForce "custom";
          "workbench.colorTheme" = lib.mkForce "Catppuccin ${flavorUpper}";
          "workbench.iconTheme" = lib.mkForce "catppuccin-${flavor}";
        };
      };
    };

    wayland.windowManager.hyprland.extraConfig = ''
      exec-once=hyprctl setcursor catppuccin-${flavor}-${accent}-cursors ${toString thm.cursorSize}
    '';

    # GTK
    gtk = {
      enable = true;
      theme = {
        name = "Catppuccin-${flavorUpper}-${sizeUpper}-${accentUpper}-${gtkTheme}";
        package = pkgs.catppuccin-gtk.override {
          inherit tweaks;
          accents = [ accent ];
          variant = flavor;
        };
      };
      cursorTheme = {
        name = "catppuccin-${flavor}-${accent}-cursors";
        package = pkgs.catppuccin-cursors.${flavor + accentUpper};
      };
      iconTheme = {
        name = "Papirus-${gtkTheme}";
        package = pkgs.catppuccin-papirus-folders.override { inherit accent flavor; };
      };
      font = {
        name = "${thm.fonts.main.family}";
        size = thm.fontSizes.normal.int;
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

  themes.base16.extraParams = {
    iconTheme = lib.mkForce "Papirus-${gtkTheme}";
    iconPackage = lib.mkForce (pkgs.catppuccin-papirus-folders.override { inherit accent flavor; });
    cursorPackage = lib.mkForce (pkgs.catppuccin-cursors.${flavor + accentUpper});
    cursorTheme = lib.mkForce "catppuccin-${flavor}-${accent}-cursors";
    cursorSize = lib.mkForce 24;
  };
}