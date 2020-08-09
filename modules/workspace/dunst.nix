{ pkgs, config, lib, ... }:
let thm = config.lib.base16.theme;
in {
  home-manager.users.alukard = {
    services.dunst = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      settings = {
        global = {
          geometry = "500x5-30+50";
          transparency = 10;
          frame_color = "#${thm.base05-hex}";
          separator_color = "#${thm.base05-hex}";
          font = "${thm.font} ${thm.fontSize}";
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
          foreground = "#${thm.base03-hex}";
          timeout = 5;
        };

        urgency_normal = {
          background = "#${thm.base02-hex}";
          foreground = "#${thm.base05-hex}";
          timeout = 10;
        };

        urgency_critical = {
          background = "#${thm.base08-hex}";
          foreground = "#${thm.base06-hex}";
          timeout = 15;
        };
      };
    };
    xsession.windowManager.i3.config.startup =
    [{ command = "${pkgs.dunst}/bin/dunst"; }];
  };
}
