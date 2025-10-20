{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    hasSuffix
    mapAttrs
    mkEnableOption
    mkIf
    ;
  cfg = config.ataraxia.programs.mimeapps;
  apps = config.defaultApplications;

  getDesktop = mapAttrs (_: v: if (v ? desktop) then v.desktop else v.cmd);
  mimeList =
    mimeAttrs:
    mapAttrs (_: v: if (hasSuffix ".desktop" v) then v else "${v}.desktop") (getDesktop mimeAttrs);
in
{
  options.ataraxia.programs.mimeapps = {
    enable = mkEnableOption "Enable mimeapps";
  };

  config = mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = mimeList {
        "text/html" = apps.browser;
        "x-scheme-handler/http" = apps.browser;
        "x-scheme-handler/https" = apps.browser;
        "x-scheme-handler/about" = apps.browser;
        "x-scheme-handler/unknown" = apps.browser;

        "message/rfc822" = apps.mail;
        "x-scheme-handler/mailto" = apps.mail;

        "x-scheme-handler/tg" = apps.messenger;

        "application/x-bittorrent" = apps.torrent;

        "image/jpeg" = apps.image;
        "image/png" = apps.image;
        "image/gif" = apps.image;
        "image/bmp" = apps.image;
        "image/svg+xml" = apps.image;
        "image/webp" = apps.image;

        "application/zip" = apps.archive;
        "application/x-rar" = apps.archive;
        "application/x-7z-compressed" = apps.archive;
        "application/x-tar" = apps.archive;
        "application/gzip" = apps.archive;
        "application/x-bzip2" = apps.archive;

        "inode/directory" = apps.fm;

        "video/mp4" = apps.media-player;
        "video/x-matroska" = apps.media-player;
        "video/webm" = apps.media-player;
        "video/x-flv" = apps.media-player;
        "video/quicktime" = apps.media-player;
        "video/x-msvideo" = apps.media-player;
        "video/x-ms-wmv" = apps.media-player;
        "audio/mpeg" = apps.media-player;
        "audio/ogg" = apps.media-player;
        "audio/x-wav" = apps.media-player;
        "audio/flac" = apps.media-player;
        "audio/x-ms-wma" = apps.media-player;
        "audio/x-aac" = apps.media-player;
        "audio/opus" = apps.media-player;
        "video/x-m4v" = apps.media-player;
        "video/3gpp" = apps.media-player;
        "video/x-ms-asf" = apps.media-player;

        "application/pdf" = apps.document-viewer;
        "application/epub+zip" = apps.document-viewer;
        "image/vnd.djvu" = apps.document-viewer;
        "application/postscript" = apps.document-viewer;

        "text/plain" = apps.editor;
        "text/markdown" = apps.editor;
        "text/x-shellscript" = apps.editor;
        "text/css" = apps.editor;
        "text/csv" = apps.editor;
        "application/json" = apps.editor;
        "text/xml" = apps.editor;
        "application/xml" = apps.editor;
        "application/javascript" = apps.editor;
        "text/x-java-source" = apps.editor;
        "text/x-python" = apps.editor;
        "application/x-python-code" = apps.editor;
        "text/x-csrc" = apps.editor;
        "text/x-c++src" = apps.editor;
        "text/x-h" = apps.editor;
        "text/x-c++hdr" = apps.editor;
        "application/x-desktop" = apps.editor;
        "application/x-nix" = apps.editor;
      };
    };
  };
}
