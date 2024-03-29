{ config, pkgs, ... }: {
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
  ];

  environment.sessionVariables = {
    EDITOR = config.defaultApplications.editor.cmd;
    VISUAL = config.defaultApplications.editor.cmd;
  };

  home-manager.users.${config.mainuser} = {
    home.activation."mimeapps-remove" = {
      before = [ "checkLinkTargets" ];
      after = [ ];
      data = "rm -f /home/${config.mainuser}/.config/mimeapps.list";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        with config.defaultApplications;
        builtins.mapAttrs (_name: value:
          if value ? desktop then [ "${value.desktop}.desktop" ] else value) {
            "text/html" = browser;
            "inode/directory" = fm;
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
            "x-scheme-handler/element" = matrix;
          };
    };
  };
}