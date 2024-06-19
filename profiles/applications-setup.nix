{ config, pkgs, ... }: {
  home-manager.users.${config.mainuser} = {
    home.activation."mimeapps-remove" = {
      before = [ "checkLinkTargets" ];
      after = [ ];
      data = "rm -f /home/${config.mainuser}/.config/mimeapps.list";
    };

    xdg.mimeApps = {
      enable = true;
      associations.added = with config.defaultApplications;
        builtins.mapAttrs (_name: value:
          if value ? desktop then [ "${value.desktop}.desktop" ] else value) {
            "application/pdf" = pdf;
            "application/x-extension-htm" = browser;
            "application/x-extension-html" = browser;
            "application/x-extension-shtml" = browser;
            "application/x-extension-xht" = browser;
            "application/x-extension-xhtml" = browser;
            "application/xhtml+xml" = browser;
            "text/html" = browser;
            "x-scheme-handler/chrome" = browser;
            "x-scheme-handler/ftp" = browser;
            "x-scheme-handler/http" = browser;
            "x-scheme-handler/https" = browser;
          };
      defaultApplications =
        with config.defaultApplications;
        builtins.mapAttrs (_name: value:
          if value ? desktop then [ "${value.desktop}.desktop" ] else value) {
            # application
            "application/*tar" = archive;
            "application/7z" = archive;
            "application/eps" =  pdf;
            "application/msword" = office;
            "application/ogg" =  media-player;
            "application/pdf" = pdf;
            "application/postscript" =  pdf;
            "application/rar" = archive;
            "application/sdp" =  media-player;
            "application/smil" =  media-player;
            "application/streamingmedia" =  media-player;
            "application/vnd.oasis.opendocument.presentation" = office;
            "application/vnd.oasis.opendocument.spreadsheet" = office;
            "application/vnd.oasis.opendocument.text" = office;
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = office;
            "application/vnd.rar" =  archive;
            "application/vnd.rn-realmedia-vbr" =  media-player;
            "application/vnd.rn-realmedia" =  media-player;
            "application/x-bittorrent" = torrent;
            "application/x-eps" =  pdf;
            "application/x-extension-htm" = browser;
            "application/x-extension-html" = browser;
            "application/x-extension-shtml" = browser;
            "application/x-extension-xht" = browser;
            "application/x-extension-xhtml" = browser;
            "application/x-flash-video" =  media-player;
            "application/x-ogg" =  media-player;
            "application/x-shellscript" = editor;
            "application/x-smil" =  media-player;
            "application/x-streamingmedia" =  media-player;
            "application/xhtml+xml" = browser;
            "application/zip" = archive;
            # "application/rss+xml" = editor;
            # "application/x-calendar" = "google-calendar-import.desktop";
            # "application/x-java-archive" = "java.desktop";
            # audio
            "audio/aac" =  media-player;
            "audio/ac3" =  media-player;
            "audio/AMR" =  media-player;
            "audio/flac" =  media-player;
            "audio/m4a" =  media-player;
            "audio/mp1" =  media-player;
            "audio/mp2" =  media-player;
            "audio/mp3" =  media-player;
            "audio/mp4" =  media-player;
            "audio/mpeg" =  media-player;
            "audio/mpegurl" =  media-player;
            "audio/mpg" =  media-player;
            "audio/ogg" =  media-player;
            "audio/rn-mpeg" =  media-player;
            "audio/scpls" =  media-player;
            "audio/vnd.rn-realaudio" =  media-player;
            "audio/wav" =  media-player;
            "audio/x-aac" =  media-player;
            "audio/x-ape" =  media-player;
            "audio/x-flac" =  media-player;
            "audio/x-m4a" =  media-player;
            "audio/x-mp1" =  media-player;
            "audio/x-mp2" =  media-player;
            "audio/x-mp3" =  media-player;
            "audio/x-mpeg" =  media-player;
            "audio/x-mpegurl" =  media-player;
            "audio/x-mpg" =  media-player;
            "audio/x-ms-wma" =  media-player;
            "audio/x-pls" =  media-player;
            "audio/x-pn-realaudio" =  media-player;
            "audio/x-pn-windows-pcm" =  media-player;
            "audio/x-realaudio" =  media-player;
            "audio/x-scpls" =  media-player;
            "audio/x-shorten" =  media-player;
            "audio/x-tta" =  media-player;
            "audio/x-vorbis+ogg" =  media-player;
            "audio/x-wav" =  media-player;
            "audio/x-wavpack" =  media-player;
            # image
            "image/bmp" = image;
            "image/eps" =  pdf;
            "image/gif" = image;
            "image/jpeg" = image;
            "image/jpg" = image;
            "image/pjpeg" = image;
            "image/png" = image;
            "image/tiff" = image;
            "image/vnd.djvu" = pdf;
            "image/webp" = image;
            "image/x-bmp" = image;
            "image/x-canon-cr2" = image;
            # "image/x-dcraw" = "nufraw.desktop";
            "image/x-eps" =  pdf;
            "image/x-pcx" = image;
            "image/x-png" = image;
            "image/x-portable-anymap" = image;
            "image/x-portable-bitmap" = image;
            "image/x-portable-graymap" = image;
            "image/x-portable-pixmap" = image;
            "image/x-tga" = image;
            "image/x-xbitmap" = image;
            # text
            # "text/calendar" = "google-calendar-import.desktop";
            "text/csv" = editor;
            "text/html" = browser;
            "text/plain" = editor;
            "text/rhtml" = editor;
            "text/x-java" = editor;
            "text/x-markdown" = editor;
            "text/x-python" = editor;
            "text/x-readme" = editor;
            "text/x-tex" = editor;
            # video
            "video/AV1" =  media-player;
            "video/H264" =  media-player;
            "video/H265" =  media-player;
            "video/matroska" =  media-player;
            "video/mp2t" =  media-player;
            "video/mp4" =  media-player;
            "video/MPV" =  media-player;
            "video/mpeg" =  media-player;
            "video/msvideo" =  media-player;
            "video/ogg" =  media-player;
            "video/quicktime" =  media-player;
            "video/vnd.rn-realvideo" =  media-player;
            "video/webm" =  media-player;
            "video/VP8" =  media-player;
            "video/VP9" =  media-player;
            "video/x-avi" =  media-player;
            "video/x-fli" =  media-player;
            "video/x-flv" =  media-player;
            "video/x-matroska" =  media-player;
            "video/x-mpeg" =  media-player;
            "video/x-mpeg2" =  media-player;
            "video/x-ms-afs" =  media-player;
            "video/x-ms-asf" =  media-player;
            "video/x-ms-wmv" =  media-player;
            "video/x-ms-wmx" =  media-player;
            "video/x-ms-wvxvideo" =  media-player;
            "video/x-msvideo" =  media-player;
            "video/x-ogm+ogg" =  media-player;
            "video/x-theora" =  media-player;
            # x-scheme-handler
            "x-scheme-handler/about" = browser;
            "x-scheme-handler/chrome" = browser;
            "x-scheme-handler/element" = matrix;
            "x-scheme-handler/ftp" = browser;
            "x-scheme-handler/http" = browser;
            "x-scheme-handler/https" = browser;
            # "x-scheme-handler/ics" = "google-calendar-import.desktop";
            "x-scheme-handler/magnet" = torrent;
            "x-scheme-handler/mailto" = mail;
            "x-scheme-handler/spotify" = spotify;
            "x-scheme-handler/terminal" = term;
            # other
            "inode/directory" = fm;
            "inode/mount-point" = fm;
            "inode/x-empty" = editor;
          };
    };
  };
}