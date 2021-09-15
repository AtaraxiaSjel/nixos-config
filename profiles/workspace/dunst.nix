{ pkgs, config, lib, ... }:
let
  thm = config.lib.base16.theme;
in {
  home-manager.users.alukard = {
    services.dunst = {
      enable = true;
      iconTheme = {
        name = "${thm.iconTheme}";
        package = thm.iconPackage;
      };
      settings = {
        global = {
          geometry = "500x5-30+50";
          transparency = 10;
          frame_color = "#${thm.base05-hex}";
          separator_color = "#${thm.base05-hex}";
          font = "${thm.fonts.main.family} ${thm.fontSizes.normal.str}";
          padding = 15;
          horizontal_padding = 17;
          word_wrap = true;
          follow = "keyboard";
          format = ''
            %s %p %I
            %b'';
          markup = "full";
        };

        urgency_low = {
          background = "#${thm.base01-hex}";
          foreground = "#${thm.base05-hex}";
          timeout = 8;
        };

        urgency_normal = {
          background = "#${thm.base01-hex}";
          foreground = "#${thm.base08-hex}";
          timeout = 12;
        };

        urgency_critical = {
          background = "#${thm.base01-hex}";
          foreground = "#${thm.base0D-hex}";
          timeout = 20;
        };
      };
    };
    xsession.windowManager.i3.config.startup =
    [{ command = "${pkgs.dunst}/bin/dunst"; }];
  };
}
