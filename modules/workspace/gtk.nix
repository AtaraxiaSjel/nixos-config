{ pkgs, config, lib, inputs, ... }:
let
  thm = config.lib.base16.theme;
  materia_colors = pkgs.writeTextFile {
    name = "gtk-generated-colors";
    # https://github.com/themix-project/themix-plugin-base16/blob/453cccbd2e22f69078c6ded894421c4c0f943bc0/oomox_plugin.py#L424
    # text = ''
    #   BG=${thm.base00-hex}
    #   FG=${thm.base07-hex}
    #   BTN_BG=${thm.base00-hex}
    #   BTN_FG=${thm.base07-hex}
    #   MENU_BG=${thm.base00-hex}
    #   MENU_FG=${thm.base07-hex}
    #   ACCENT_BG=${thm.base02-hex}
    #   SEL_BG=${thm.base0D-hex}
    #   SEL_FG=${thm.base00-hex}
    #   TXT_BG=${thm.base00-hex}
    #   TXT_FG=${thm.base07-hex}
    #   HDR_BTN_BG=${thm.base00-hex}
    #   HDR_BTN_FG=${thm.base07-hex}
    #   WM_BORDER_FOCUS=${thm.base02-hex}
    #   WM_BORDER_UNFOCUS=${thm.base01-hex}
    #   MATERIA_STYLE_COMPACT=True
    #   MATERIA_COLOR_VARIANT=dark
    #   UNITY_DEFAULT_LAUNCHER_STYLE=False
    #   NAME=generated
    # '';
    text = ''
      BG=${thm.base01-hex}
      FG=${thm.base06-hex}
      HDR_BG=${thm.base00-hex}
      HDR_FG=${thm.base05-hex}
      SEL_BG=${thm.base0E-hex}
      SEL_FG=${thm.base00-hex}
      ACCENT_BG=${thm.base0E-hex}
      TXT_BG=${thm.base02-hex}
      TXT_FG=${thm.base07-hex}
      BTN_BG=${thm.base00-hex}
      BTN_FG=${thm.base05-hex}
      HDR_BTN_BG=${thm.base01-hex}
      HDR_BTN_FG=${thm.base05-hex}
      ICONS_LIGHT_FOLDER=${thm.base0D-hex}
      ICONS_LIGHT=${thm.base0D-hex}
      ICONS_MEDIUM=${thm.base0E-hex}
      ICONS_DARK=${thm.base00-hex}
      MATERIA_STYLE_COMPACT=True
      MATERIA_COLOR_VARIANT=dark
      UNITY_DEFAULT_LAUNCHER_STYLE=False
      NAME=generated
    '';
  };
in {
  nixpkgs.overlays = [
    (self: super: {
      generated-gtk-theme = self.stdenv.mkDerivation rec {
        name = "generated-gtk-theme";
        src = inputs.materia-theme;
        buildInputs = with self; [ sassc bc which inkscape optipng ];
        installPhase = ''
          HOME=/build
          chmod 777 -R .
          patchShebangs .
          mkdir -p $out/share/themes
          substituteInPlace change_color.sh --replace "\$HOME/.themes" "$out/share/themes"
          echo "Changing colours:"
          ./change_color.sh -o Generated ${materia_colors}
          chmod 555 -R .
        '';
      };
    })
  ];
  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ gnome3.dconf ];
  home-manager.users.alukard = {
    gtk = {
      enable = true;
      iconTheme = {
        name = "${thm.iconTheme}";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Generated";
        package = pkgs.generated-gtk-theme;
      };
      font = {
        name = "${thm.font} ${thm.normalFontSize}";
      };
      gtk3 = {
        extraConfig = {
          gtk-cursor-theme-name = "Bibata-Modern-Classic";
        };
      };
    };

    home.sessionVariables.GTK_THEME = "Generated";
    home.sessionVariables.XDG_DATA_DIRS = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    ];
  };
  environment.sessionVariables.XDG_CURRENT_DESKTOP = "X-Generic";
}
