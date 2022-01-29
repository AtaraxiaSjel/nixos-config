{ config, pkgs, lib, ... }: {
  defaultApplications = {
    fm = {
      cmd = "${pkgs.pcmanfm}/bin/pcmanfm";
      desktop = "pcmanfm";
    };
    monitor = {
      cmd = "${pkgs.gnome.gnome-system-monitor}/bin/gnome-system-monitor";
      desktop = "gnome-system-monitor";
    };
    torrent = {
      cmd = "${pkgs.qbittorrent}/bin/qbittorrent";
      desktop = "qbittorrent";
    };
    archive = {
      cmd = "${pkgs.xarchiver}/bin/xarchiver";
      desktop = "xarchiver";
    };
    messenger = {
      cmd = "${pkgs.tdesktop}/bin/telegram-desktop";
      desktop = "telegram-desktop";
    };
    # mail = {
    #   cmd = "${pkgs.trojita}/bin/trojita";
    #   desktop = "trojita";
    # };
    # text_processor = {
    #   cmd = "${pkgs.libreoffice}/bin/libreoffice";
    #   desktop = "libreoffice";
    # };
    # spreadsheet = {
    #   cmd = "${pkgs.gnumeric}/bin/gnumeric";
    #   desktop = "gnumeric";
    # };
  };

  startupApplications = with config.defaultApplications; [
    messenger.cmd
    "${pkgs.keepassxc}/bin/keepassxc --keyfile=/home/alukard/.passwords.key /home/alukard/nixos-config/misc/Passwords.kdbx"
    # "${term.cmd} -e spt"
    # "${pkgs.feh}/bin/feh --bg-fill ${/. + ../misc/wallpaper}"
  ];

  environment.sessionVariables = {
    EDITOR = config.defaultApplications.editor.cmd;
    VISUAL = config.defaultApplications.editor.cmd;
  };

  home-manager.users.alukard = {
    home.activation."mimeapps-remove" = {
      before = [ "checkLinkTargets" ];
      after = [ ];
      data = "rm -f /home/alukard/.config/mimeapps.list";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        with config.defaultApplications;
        builtins.mapAttrs (name: value:
          if value ? desktop then [ "${value.desktop}.desktop" ] else value) {
            "text/html" = browser;
            "image/*" = { desktop = "org.gnome.eog"; };
            "application/x-bittorrent" = torrent;
            "application/zip" = archive;
            "application/rar" = archive;
            "application/7z" = archive;
            "application/*tar" = archive;
            "x-scheme-handler/http" = browser;
            "x-scheme-handler/https" = browser;
            "x-scheme-handler/about" = browser;
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