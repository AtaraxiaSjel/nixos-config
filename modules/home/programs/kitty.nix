{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.kitty;

  inherit (config.theme) colors fonts;
in
{
  options.ataraxia.programs.kitty = {
    enable = mkEnableOption "Enable kitty program";
  };

  config = mkIf cfg.enable {
    defaultApplications.term = {
      cmd = "${pkgs.kitty}/bin/kitty";
      desktop = "kitty";
    };

    programs.kitty = {
      enable = true;
      # font.package = ;
      font.name = fonts.mono.family;
      font.size = fonts.size.small;
      settings = {
        background = "#${colors.color0}";
        foreground = "#${colors.color5}";
        selection_background = "#${colors.color5}";
        selection_foreground = "#${colors.color0}";
        url_color = "#${colors.color4}";
        cursor = "#${colors.color5}";
        cursor_text_color = "#${colors.color0}";
        active_border_color = "#${colors.color3}";
        inactive_border_color = "#${colors.color1}";
        active_tab_background = "#${colors.color0}";
        active_tab_foreground = "#${colors.color5}";
        inactive_tab_background = "#${colors.color1}";
        inactive_tab_foreground = "#${colors.color4}";
        tab_bar_background = "#${colors.color1}";
        wayland_titlebar_color = "#${colors.color0}";
        macos_titlebar_color = "#${colors.color0}";

        # normal
        color = "#${colors.color0}";
        color1 = "#${colors.color8}";
        color2 = "#${colors.color11}";
        color3 = "#${colors.color10}";
        color4 = "#${colors.color13}";
        color5 = "#${colors.color14}";
        color6 = "#${colors.color12}";
        color7 = "#${colors.color5}";

        # bright
        color8 = "#${colors.color3}";
        color9 = "#${colors.color8}";
        color10 = "#${colors.color11}";
        color11 = "#${colors.color10}";
        color12 = "#${colors.color13}";
        color13 = "#${colors.color14}";
        color14 = "#${colors.color12}";
        color15 = "#${colors.color7}";

        # extended base16 colors
        color16 = "#${colors.color9}";
        color17 = "#${colors.color15}";
        color18 = "#${colors.color1}";
        color19 = "#${colors.color2}";
        color20 = "#${colors.color4}";
        color21 = "#${colors.color6}";

        enable_audio_bell = false;
        confirm_os_window_close = 0;
      };
    };
  };
}
