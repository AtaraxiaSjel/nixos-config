{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    ;
  inherit (lib.types) bool enum;
  cfg = config.ataraxia.theme.catppuccin;
  # this capitalizes the first letter in a string.
  mkUpper =
    str:
    (lib.toUpper (builtins.substring 0 1 str)) + (builtins.substring 1 (builtins.stringLength str) str);
in
{
  options.ataraxia.theme.catppuccin = {
    enable = mkEnableOption "Enable catppuccin theme";
    gtk = mkOption {
      type = bool;
      default = true;
      description = "Enable gtk settings";
    };
    accent = mkOption {
      type = enum [
        "blue"
        "flamingo"
        "green"
        "lavender"
        "maroon"
        "mauve"
        "peach"
        "pink"
        "red"
        "rosewater"
        "sapphire"
        "sky"
        "teal"
        "yellow"
      ];
      default = "mauve";
      description = "Catppuccin accent";
    };
    flavor = mkOption {
      type = enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "mocha";
      description = "Catppuccin flavor";
    };
  };

  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  config = mkMerge [
    (mkIf cfg.enable {
      catppuccin.accent = cfg.accent;
      catppuccin.flavor = cfg.flavor;
      catppuccin.enable = true;
      catppuccin.waybar.mode = "prependImport"; # or "createLink"

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
        "editor.semanticHighlighting.enabled" = lib.mkForce true;
        "terminal.integrated.minimumContrastRatio" = lib.mkForce 1;
        "window.titleBarStyle" = lib.mkForce "custom";
        "workbench.colorTheme" = lib.mkForce "Catppuccin ${mkUpper cfg.flavor}";
        "workbench.iconTheme" = lib.mkForce "catppuccin-${cfg.flavor}";
      };
    })
    (mkIf (cfg.enable && cfg.gtk) {
      gtk = {
        enable = true;
        theme = {
          name = "catppuccin-${cfg.flavor}-${cfg.accent}-standard+normal";
          package = pkgs.catppuccin-gtk.override {
            accents = [ cfg.accent ];
            tweaks = [ "normal" ];
            variant = cfg.flavor;
          };
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.catppuccin-papirus-folders.override { inherit (cfg) accent flavor; };
        };
        font = {
          package = config.theme.fonts.sans.package;
          name = config.theme.fonts.sans.family;
          size = config.theme.fonts.size.normal;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };
      home.sessionVariables.GTK_THEME = config.gtk.theme.name;
      xdg.configFile =
        let
          gtk4Dir = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0";
        in
        {
          "gtk-4.0/assets".source = "${gtk4Dir}/assets";
          "gtk-4.0/gtk.css".source = "${gtk4Dir}/gtk.css";
          "gtk-4.0/gtk-dark.css".source = "${gtk4Dir}/gtk-dark.css";
        };
    })
  ];
}
