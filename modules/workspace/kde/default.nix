{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in
{
  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];
  # services.dbus.packages = [
  #   pkgs.plasma5.xdg-desktop-portal-kde
  #   pkgs.flatpak
  #   pkgs.firefox
  #   pkgs.systemd
  #   pkgs.papirus-icon-theme
  #   pkgs.kdeApplications.kdegraphics-thumbnailers
  #   pkgs.kdeFrameworks.baloo
  #   pkgs.kdeFrameworks.kio
  #   pkgs.kdeApplications.kio-extras
  #   pkgs.kdeApplications.dolphin-plugins
  # ];
  # environment.systemPackages = [
  #   pkgs.kdeFrameworks.baloo
  #   pkgs.kdeFrameworks.kio
  #   pkgs.kdeApplications.kio-extras
  #   pkgs.kdeApplications.kdegraphics-thumbnailers
  #   pkgs.kdeApplications.dolphin-plugins
  # ];
  # services.udev.packages = [
  #   pkgs.libmtp
  #   pkgs.media-player-info
  # ];

  environment.sessionVariables = {
    # DESKTOP_SESSION = "kde";
    QT_XFT = "true";
    QT_SELECT = "5";
    # XDG_CURRENT_DESKTOP = "KDE";
    KDE_SESSION_VERSION = "5";
    QT_SCALE_FACTOR = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    # DE = "kde";
    QT_QPA_PLATFORMTHEME = "kde";
    KDEDIRS = "/run/current-system/sw:/run/current-system/sw/share/kservices5:/run/current-system/sw/share/kservicetypes5:/run/current-system/sw/share/kxmlgui5";
  };

  home-manager.users.alukard.xdg.configFile."kdeglobals".text = lib.generators.toINI {} {
    "Colors:Button" = {
      BackgroundAlternate = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      BackgroundNormal = "${thm.base00-rgb-r}, ${thm.base00-rgb-g}, ${thm.base00-rgb-b}";
      DecorationFocus = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      DecorationHover = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundActive = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundInactive = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      ForegroundLink = "${thm.base0D-rgb-r}, ${thm.base0D-rgb-g}, ${thm.base0D-rgb-b}";
      ForegroundNegative = "${thm.base08-rgb-r}, ${thm.base08-rgb-g}, ${thm.base08-rgb-b}";
      ForegroundNeutral = "${thm.base09-rgb-r}, ${thm.base09-rgb-g}, ${thm.base09-rgb-b}";
      ForegroundNormal = "${thm.base05-rgb-r}, ${thm.base05-rgb-g}, ${thm.base05-rgb-b}";
      ForegroundPositive = "${thm.base0B-rgb-r}, ${thm.base0B-rgb-g}, ${thm.base0B-rgb-b}";
      ForegroundVisited = "${thm.base03-rgb-r}, ${thm.base03-rgb-g}, ${thm.base03-rgb-b}";
    };
    "Colors:Complementary" = {
      BackgroundAlternate = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      BackgroundNormal = "${thm.base00-rgb-r}, ${thm.base00-rgb-g}, ${thm.base00-rgb-b}";
      DecorationFocus = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      DecorationHover = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundActive = "${thm.base09-rgb-r}, ${thm.base09-rgb-g}, ${thm.base09-rgb-b}";
      ForegroundInactive = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      ForegroundLink = "${thm.base0D-rgb-r}, ${thm.base0D-rgb-g}, ${thm.base0D-rgb-b}";
      ForegroundNegative = "${thm.base08-rgb-r}, ${thm.base08-rgb-g}, ${thm.base08-rgb-b}";
      ForegroundNeutral = "${thm.base0A-rgb-r}, ${thm.base0A-rgb-g}, ${thm.base0A-rgb-b}";
      ForegroundNormal = "${thm.base05-rgb-r}, ${thm.base05-rgb-g}, ${thm.base05-rgb-b}";
      ForegroundPositive = "${thm.base0B-rgb-r}, ${thm.base0B-rgb-g}, ${thm.base0B-rgb-b}";
      ForegroundVisited = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
    };
    "Colors:Selection" = {
      BackgroundAlternate = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      BackgroundNormal = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      DecorationFocus = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      DecorationHover = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundActive = "${thm.base05-rgb-r}, ${thm.base05-rgb-g}, ${thm.base05-rgb-b}";
      ForegroundInactive = "${thm.base05-rgb-r}, ${thm.base05-rgb-g}, ${thm.base05-rgb-b}";
      ForegroundLink = "${thm.base0D-rgb-r}, ${thm.base0D-rgb-g}, ${thm.base0D-rgb-b}";
      ForegroundNegative = "${thm.base08-rgb-r}, ${thm.base08-rgb-g}, ${thm.base08-rgb-b}";
      ForegroundNeutral = "${thm.base09-rgb-r}, ${thm.base09-rgb-g}, ${thm.base09-rgb-b}";
      ForegroundNormal = "${thm.base05-rgb-r}, ${thm.base05-rgb-g}, ${thm.base05-rgb-b}";
      ForegroundPositive = "${thm.base0B-rgb-r}, ${thm.base0B-rgb-g}, ${thm.base0B-rgb-b}";
      ForegroundVisited = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
    };
    "Colors:Tooltip" = {
      BackgroundAlternate = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      BackgroundNormal = "${thm.base00-rgb-r}, ${thm.base00-rgb-g}, ${thm.base00-rgb-b}";
      DecorationFocus = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      DecorationHover = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundActive = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundInactive = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      ForegroundLink = "${thm.base0D-rgb-r}, ${thm.base0D-rgb-g}, ${thm.base0D-rgb-b}";
      ForegroundNegative = "${thm.base08-rgb-r}, ${thm.base08-rgb-g}, ${thm.base08-rgb-b}";
      ForegroundNeutral = "${thm.base09-rgb-r}, ${thm.base09-rgb-g}, ${thm.base09-rgb-b}";
      ForegroundNormal = "${thm.base05-rgb-r}, ${thm.base05-rgb-g}, ${thm.base05-rgb-b}";
      ForegroundPositive = "${thm.base0B-rgb-r}, ${thm.base0B-rgb-g}, ${thm.base0B-rgb-b}";
      ForegroundVisited = "${thm.base03-rgb-r}, ${thm.base03-rgb-g}, ${thm.base03-rgb-b}";
    };
    "Colors:View" = {
      BackgroundAlternate = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      BackgroundNormal = "${thm.base00-rgb-r}, ${thm.base00-rgb-g}, ${thm.base00-rgb-b}";
      DecorationFocus = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      DecorationHover = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundActive = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundInactive = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      ForegroundLink = "${thm.base0D-rgb-r}, ${thm.base0D-rgb-g}, ${thm.base0D-rgb-b}";
      ForegroundNegative = "${thm.base08-rgb-r}, ${thm.base08-rgb-g}, ${thm.base08-rgb-b}";
      ForegroundNeutral = "${thm.base09-rgb-r}, ${thm.base09-rgb-g}, ${thm.base09-rgb-b}";
      ForegroundNormal = "${thm.base05-rgb-r}, ${thm.base05-rgb-g}, ${thm.base05-rgb-b}";
      ForegroundPositive = "${thm.base0B-rgb-r}, ${thm.base0B-rgb-g}, ${thm.base0B-rgb-b}";
      ForegroundVisited = "${thm.base03-rgb-r}, ${thm.base03-rgb-g}, ${thm.base03-rgb-b}";
    };
    "Colors:Window" = {
      BackgroundAlternate = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      BackgroundNormal = "${thm.base00-rgb-r}, ${thm.base00-rgb-g}, ${thm.base00-rgb-b}";
      DecorationFocus = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      DecorationHover = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundActive = "${thm.base02-rgb-r}, ${thm.base02-rgb-g}, ${thm.base02-rgb-b}";
      ForegroundInactive = "${thm.base01-rgb-r}, ${thm.base01-rgb-g}, ${thm.base01-rgb-b}";
      ForegroundLink = "${thm.base0D-rgb-r}, ${thm.base0D-rgb-g}, ${thm.base0D-rgb-b}";
      ForegroundNegative = "${thm.base08-rgb-r}, ${thm.base08-rgb-g}, ${thm.base08-rgb-b}";
      ForegroundNeutral = "${thm.base09-rgb-r}, ${thm.base09-rgb-g}, ${thm.base09-rgb-b}";
      ForegroundNormal = "${thm.base05-rgb-r}, ${thm.base05-rgb-g}, ${thm.base05-rgb-b}";
      ForegroundPositive = "${thm.base0B-rgb-r}, ${thm.base0B-rgb-g}, ${thm.base0B-rgb-b}";
      ForegroundVisited = "${thm.base03-rgb-r}, ${thm.base03-rgb-g}, ${thm.base03-rgb-b}";
    };
    General = {
      ColorScheme = "Generated";
      Name = "Generated";
      fixed = "${thm.fontMono},11,-1,5,50,0,0,0,0,0";
      font = "${thm.font},11,-1,5,50,0,0,0,0,0";
      menuFont = "${thm.font},11,-1,5,50,0,0,0,0,0";
      shadeSortColumn = true;
      smallestReadableFont = "${thm.font},8,-1,5,57,0,0,0,0,0,Medium";
      toolBarFont = "${thm.font},11,-1,5,50,0,0,0,0,0";
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
    Icons = { Theme = "${thm.iconsTheme}"; };
  };
}
