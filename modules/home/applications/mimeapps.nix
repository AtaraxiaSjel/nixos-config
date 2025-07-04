{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.mimeapps;
  apps = config.defaultApplications;
in
{
  options.ataraxia.programs.mimeapps = {
    enable = mkEnableOption "Enable mimeapps";
  };

  config = mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = apps.browser.desktop;
        "x-scheme-handler/http" = apps.browser.desktop;
        "x-scheme-handler/https" = apps.browser.desktop;
        "x-scheme-handler/about" = apps.browser.desktop;
        "x-scheme-handler/unknown" = apps.browser.desktop;

        "message/rfc822" = apps.mail.desktop;
        "x-scheme-handler/mailto" = apps.mail.desktop;

        "x-scheme-handler/tg" = apps.messenger.desktop;

        "application/x-bittorrent" = apps.torrent.desktop;

        "image/jpeg" = apps.image.desktop;
        "image/png" = apps.image.desktop;
        "image/gif" = apps.image.desktop;
        "image/bmp" = apps.image.desktop;
        "image/svg+xml" = apps.image.desktop;
        "image/webp" = apps.image.desktop;

        "application/zip" = apps.archive.desktop;
        "application/x-rar" = apps.archive.desktop;
        "application/x-7z-compressed" = apps.archive.desktop;
        "application/x-tar" = apps.archive.desktop;
        "application/gzip" = apps.archive.desktop;
        "application/x-bzip2" = apps.archive.desktop;

        "inode/directory" = apps.fm.desktop;

        "video/mp4" = apps.media-player.desktop;
        "video/x-matroska" = apps.media-player.desktop;
        "video/webm" = apps.media-player.desktop;
        "video/x-flv" = apps.media-player.desktop;
        "video/quicktime" = apps.media-player.desktop;
        "video/x-msvideo" = apps.media-player.desktop;
        "video/x-ms-wmv" = apps.media-player.desktop;
        "audio/mpeg" = apps.media-player.desktop;
        "audio/ogg" = apps.media-player.desktop;
        "audio/x-wav" = apps.media-player.desktop;
        "audio/flac" = apps.media-player.desktop;
        "audio/x-ms-wma" = apps.media-player.desktop;
        "audio/x-aac" = apps.media-player.desktop;
        "audio/opus" = apps.media-player.desktop;
        "video/x-m4v" = apps.media-player.desktop;
        "video/3gpp" = apps.media-player.desktop;
        "video/x-ms-asf" = apps.media-player.desktop;

        "application/pdf" = apps.document-viewer.desktop;
        "application/epub+zip" = apps.document-viewer.desktop;
        "image/vnd.djvu" = apps.document-viewer.desktop;
        "application/postscript" = apps.document-viewer.desktop;

        "text/plain" = apps.editor.desktop;
        "text/markdown" = apps.editor.desktop;
        "text/x-shellscript" = apps.editor.desktop;
        "text/css" = apps.editor.desktop;
        "text/csv" = apps.editor.desktop;
        "application/json" = apps.editor.desktop;
        "text/xml" = apps.editor.desktop;
        "application/xml" = apps.editor.desktop;
        "application/javascript" = apps.editor.desktop;
        "text/x-java-source" = apps.editor.desktop;
        "text/x-python" = apps.editor.desktop;
        "application/x-python-code" = apps.editor.desktop;
        "text/x-csrc" = apps.editor.desktop;
        "text/x-c++src" = apps.editor.desktop;
        "text/x-h" = apps.editor.desktop;
        "text/x-c++hdr" = apps.editor.desktop;
        "application/x-desktop" = apps.editor.desktop;
        "application/x-nix" = apps.editor.desktop;
      };
    };
  };
}
