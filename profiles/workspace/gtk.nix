{ pkgs, config, lib, inputs, ... }:
let
  thm = config.lib.base16.theme;
in {
  nixpkgs.overlays = [
    (self: super: {
      generated-gtk-theme =
        pkgs.callPackage "${inputs.rycee}/pkgs/materia-theme" {
          configBase16 = {
            name = "Generated";
            kind = "dark";
            colors = {
              base00.hex.rgb = "${thm.base00-hex}";
              base01.hex.rgb = "${thm.base00-hex}";
              base02.hex.rgb = "${thm.base00-hex}";
              base03.hex.rgb = "${thm.base03-hex}";
              base04.hex.rgb = "${thm.base04-hex}";
              base05.hex.rgb = "${thm.base05-hex}";
              base06.hex.rgb = "${thm.base06-hex}";
              base07.hex.rgb = "${thm.base07-hex}";
              base08.hex.rgb = "${thm.base08-hex}";
              base09.hex.rgb = "${thm.base09-hex}";
              base0A.hex.rgb = "${thm.base0A-hex}";
              base0B.hex.rgb = "${thm.base0B-hex}";
              base0C.hex.rgb = "${thm.base0C-hex}";
              base0D.hex.rgb = "${thm.base0D-hex}";
              base0E.hex.rgb = "${thm.base0E-hex}";
              base0F.hex.rgb = "${thm.base0F-hex}";
            };
          };
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
        package = thm.iconPackage;
      };
      theme = {
        name = "Generated";
        package = pkgs.generated-gtk-theme;
      };
      font = {
        name = "${thm.font}";
        size = lib.toInt thm.normalFontSize;
      };
    };
    home.sessionVariables.XDG_DATA_DIRS = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    ];
    home.sessionVariables.GTK_THEME = "Generated";
  };
}
