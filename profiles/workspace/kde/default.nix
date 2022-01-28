{ pkgs, lib, config, ... }:
with config.lib.base16.theme; {
  services.dbus.packages =
    [ pkgs.systemd iconPackage ];
  services.udev.packages = [ pkgs.libmtp pkgs.media-player-info ];

  qt5.enable = false;

  environment.sessionVariables = {
    QT_XFT = "true";
    QT_SELECT = "5";
    KDE_SESSION_VERSION = "5";
    QT_SCALE_FACTOR = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_QPA_PLATFORMTHEME = "kde";
    KDEDIRS =
      "/run/current-system/sw:/run/current-system/sw/share/kservices5:/run/current-system/sw/share/kservicetypes5:/run/current-system/sw/share/kxmlgui5";
  };
  home-manager.users.alukard = {
    services.kdeconnect.enable = true;

    xdg.configFile."kdeglobals".text = lib.generators.toGitINI {
      "Colors:Button" = {
        BackgroundAlternate = base01-hex;
        BackgroundNormal = base01-hex;
        DecorationFocus = base02-hex;
        DecorationHover = base02-hex;
        ForegroundActive = base05-hex;
        ForegroundInactive = base01-hex;
        ForegroundLink = base0D-hex;
        ForegroundNegative = base08-hex;
        ForegroundNeutral = base09-hex;
        ForegroundNormal = base05-hex;
        ForegroundPositive = base0B-hex;
        ForegroundVisited = base03-hex;
      };
      "Colors:Complementary" = {
        BackgroundAlternate = base01-hex;
        BackgroundNormal = base03-hex;
        DecorationFocus = base02-hex;
        DecorationHover = base02-hex;
        ForegroundActive = base09-hex;
        ForegroundInactive = base01-hex;
        ForegroundLink = base0D-hex;
        ForegroundNegative = base08-hex;
        ForegroundNeutral = base0A-hex;
        ForegroundNormal = base05-hex;
        ForegroundPositive = base0B-hex;
        ForegroundVisited = base02-hex;
      };
      "Colors:Selection" = {
        BackgroundAlternate = base0D-hex;
        BackgroundNormal = base0D-hex;
        DecorationFocus = base0D-hex;
        DecorationHover = base0D-hex;
        ForegroundActive = base05-hex;
        ForegroundInactive = base05-hex;
        ForegroundLink = base0D-hex;
        ForegroundNegative = base08-hex;
        ForegroundNeutral = base09-hex;
        ForegroundNormal = base05-hex;
        ForegroundPositive = base0B-hex;
        ForegroundVisited = base02-hex;
      };
      "Colors:Tooltip" = {
        BackgroundAlternate = base01-hex;
        BackgroundNormal = base00-hex;
        DecorationFocus = base02-hex;
        DecorationHover = base02-hex;
        ForegroundActive = base02-hex;
        ForegroundInactive = base01-hex;
        ForegroundLink = base0D-hex;
        ForegroundNegative = base08-hex;
        ForegroundNeutral = base09-hex;
        ForegroundNormal = base05-hex;
        ForegroundPositive = base0B-hex;
        ForegroundVisited = base03-hex;
      };
      "Colors:View" = {
        BackgroundAlternate = base01-hex;
        BackgroundNormal = base00-hex;
        DecorationFocus = base02-hex;
        DecorationHover = base02-hex;
        ForegroundActive = base02-hex;
        ForegroundInactive = base01-hex;
        ForegroundLink = base0D-hex;
        ForegroundNegative = base08-hex;
        ForegroundNeutral = base09-hex;
        ForegroundNormal = base05-hex;
        ForegroundPositive = base0B-hex;
        ForegroundVisited = base03-hex;
      };
      "Colors:Window" = {
        BackgroundAlternate = base01-hex;
        BackgroundNormal = base00-hex;
        DecorationFocus = base02-hex;
        DecorationHover = base02-hex;
        ForegroundActive = base02-hex;
        ForegroundInactive = base01-hex;
        ForegroundLink = base0D-hex;
        ForegroundNegative = base08-hex;
        ForegroundNeutral = base09-hex;
        ForegroundNormal = base05-hex;
        ForegroundPositive = base0B-hex;
        ForegroundVisited = base03-hex;
      };
      General = {
        ColorScheme = "Generated";
        Name = "Generated";
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
        widgetStyle = "Breeze";
      };
      Icons = { Theme = "${fonts.icon.family}"; };
    };
  };
}
