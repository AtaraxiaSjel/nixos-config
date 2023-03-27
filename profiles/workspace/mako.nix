{ pkgs, config, ... }: {
  home-manager.users.${config.mainuser} = {
    systemd.user.services.mako = {
      Service = {
        ExecStart = "${pkgs.mako}/bin/mako";
        Environment =
          [ "PATH=${pkgs.lib.makeBinPath [ pkgs.bash pkgs.mpv ]}" ];
      };
      Install = {
        After = [ "hyprland-session.target" ];
        WantedBy = [ "hyprland-session.target" ];
      };
    };
    services.mako = with config.lib.base16; {
      enable = true;
      layer = "overlay";
      font = "${theme.fonts.mono.family} ${theme.fontSizes.normal.str}";
      width = 500;
      height = 80;
      defaultTimeout = 10000;
      maxVisible = 10;
      backgroundColor = "#${theme.base00-hex}AA";
      textColor = "#${theme.base05-hex}";
      borderColor = "#${theme.base0D-hex}AA";
      progressColor = "over #${theme.base0B-hex}";
      iconPath = "${theme.iconPackage}/share/icons/${theme.iconTheme}";
      maxIconSize = 24;
      # extraConfig = let
      #   play = sound:
      #     "mpv ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/${sound}.oga";
      # in ''
      #   on-notify=exec ${play "message"}
      #   [app-name=yubikey-touch-detector]
      #   on-notify=exec ${play "service-login"}
      #   [app-name=command_complete summary~="✘.*"]
      #   on-notify=exec ${play "dialog-warning"}
      #   [app-name=command_complete summary~="✓.*"]
      #   on-notify=exec ${play "bell"}
      #   [category=osd]
      #   on-notify=none
      #   [mode=do-not-disturb]
      #   invisible=1
      #   [mode=do-not-disturb summary="Do not disturb: on"]
      #   invisible=0
      #   [mode=concentrate]
      #   invisible=1
      #   [mode=concentrate urgency=critical]
      #   invisible=0
      #   [mode=concentrate summary="Concentrate mode: on"]
      #   invisible=0
      # '';
    };
  };
}
