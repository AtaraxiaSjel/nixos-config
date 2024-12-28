{ pkgs, config, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    systemd.user.services.mako = {
      Service = {
        ExecStart = "${pkgs.mako}/bin/mako";
        Environment =
          [ "PATH=${lib.makeBinPath [ pkgs.bash pkgs.mpv ]}" ];
      };
      Install = rec {
        After = [ "graphical-session.target" ];
        WantedBy = After;
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
      # backgroundColor = "#${theme.base00-hex}AA";
      # textColor = "#${theme.base05-hex}";
      # borderColor = "#${theme.base0D-hex}AA";
      # progressColor = "over #${theme.base0B-hex}";
      iconPath = "${theme.iconPackage}/share/icons/${theme.iconTheme}";
      maxIconSize = 24;
    };
  };
}
