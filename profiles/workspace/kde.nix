{ pkgs, lib, config, ... }:
with config.lib.base16.theme; {
  services.dbus.packages =
    [ pkgs.systemd iconPackage ];
  services.udev.packages = [ pkgs.libmtp pkgs.media-player-info ];

  qt = {
    enable = false;
    style = "kvantum";
    platformTheme = "qt5ct";
  };

  # environment.systemPackages = with pkgs; [
  #   libsForQt5.qtstyleplugin-kvantum
  #   libsForQt5.qt5ct
  # ];

  environment.sessionVariables = {
    KDEDIRS =
      "/run/current-system/sw:/run/current-system/sw/share/kservices5:/run/current-system/sw/share/kservicetypes5:/run/current-system/sw/share/kxmlgui5";
  };
  home-manager.users.${config.mainuser} = {
    qt = {
      enable = true;
      style.name = "kvantum";
      platformTheme.name = "kvantum";
    };

    xdg.configFile."kdeglobals".text = lib.generators.toGitINI {
      General = {
        # ColorScheme = "Generated";
        # Name = "Generated";
        fixed = "${fonts.mono.family},${fontSizes.small.str},-1,5,50,0,0,0,0,0";
        font = "${fonts.main.family},${fontSizes.small.str},-1,5,50,0,0,0,0,0";
        menuFont = "${fonts.main.family},${fontSizes.small.str},-1,5,50,0,0,0,0,0";
        shadeSortColumn = true;
        smallestReadableFont =
          "${fonts.main.family},${fontSizes.minimal.str},-1,5,57,0,0,0,0,0,Medium";
        toolBarFont = "${fonts.main.family},${fontSizes.small.str},-1,5,50,0,0,0,0,0";
      };
      KDE = {
        DoubleClickInterval = 400;
        ShowDeleteCommand = true;
        SingleClick = false;
        StartDragDist = 4;
        StartDragTime = 500;
        WheelScrollLines = 3;
        contrast = 4;
        # widgetStyle = "Breeze";
      };
      Icons = { Theme = "${fonts.icon.family}"; };
    };
  };
}
