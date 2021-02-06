{ pkgs, config, lib, ... }:
with config.deviceSpecific;
{
  options.defaultApplications = lib.mkOption {
    type = lib.types.attrs;
    description = "Preferred applications";
  };
  config = rec {
    defaultApplications = {
      term = if (isLaptop || isVM) then {
        cmd = "${pkgs.kitty}/bin/kitty";
        desktop = "kitty";
      } else {
        cmd = "${pkgs.alacritty}/bin/alacritty";
        desktop = "alacritty";
      };
      dmenu = {
        cmd = "${pkgs.rofi}/bin/rofi -show run";
        desktop = "rofi";
      };
      editor = {
        cmd = "${pkgs.vscode}/bin/code";
        desktop = "code";
      };
      browser = {
        cmd = "${pkgs.vivaldi}/bin/vivaldi";
        desktop = "vivaldi";
      };
      fm = {
        cmd = "${pkgs.xfce4-14.thunar}/bin/thunar";
        desktop = "thunar";
      };
      monitor = {
        cmd = "${pkgs.xfce4-14.xfce4-taskmanager}/bin/xfce4-taskmanager";
        desktop = "taskmanager";
      };
      torrent = {
        cmd = "${pkgs.qbittorrent}/bin/qbittorrent";
        desktop = "qbittorrent";
      };
      archive = {
        cmd = "${pkgs.xarchiver}/bin/xarchiver";
        desktop = "xarchiver";
      };
      pdf = {
        cmd = "${pkgs.zathura}/bin/zathura";
        desktop = "zathura";
      };
      # archive = {
      #   cmd = "${pkgs.ark}/bin/ark";
      #   desktop = "org.kde.ark";
      # };
      # mail = {
      #   cmd = "${pkgs.trojita}/bin/trojita";
      #   desktop = "trojita";
      # };
      # text_processor = {
      #   cmd = "${pkgs.abiword}/bin/abiword";
      #   desktop = "abiword";
      # };
      # spreadsheet = {
      #   cmd = "${pkgs.gnumeric}/bin/gnumeric";
      #   desktop = "gnumeric";
      # };
    };

    environment.sessionVariables = {
      EDITOR = config.defaultApplications.editor.cmd;
      VISUAL = config.defaultApplications.editor.cmd;
    };

    home-manager.users.alukard.xdg.mimeApps = {
      enable = true;
      defaultApplications =
        with config.defaultApplications;
        builtins.mapAttrs (name: value:
          if value ? desktop then [ "${value.desktop}.desktop" ] else value) {
            "text/html" = browser;
            # "image/*" = { desktop = "org.gnome.eog"; };
            "application/x-bittorrent" = torrent;
            "application/zip" = archive;
            "application/rar" = archive;
            "application/7z" = archive;
            "application/*tar" = archive;
            "x-scheme-handler/http" = browser;
            "x-scheme-handler/https" = browser;
            "x-scheme-handler/about" = browser;
            "x-scheme-handler/unknown" = browser;
            # "x-scheme-handler/mailto" = mail;
            "application/pdf" = pdf;
            # "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
            #   text_processor;
            # "application/msword" = text_processor;
            # "application/vnd.oasis.opendocument.text" = text_processor;
            # "text/csv" = spreadsheet;
            # "application/vnd.oasis.opendocument.spreadsheet" = spreadsheet;
            "text/plain" = editor;
          };
    };
  };
}
