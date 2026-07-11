{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.default;

  thunarFinal =
    with pkgs;
    (thunar.override {
      thunarPlugins = [
        thunar-archive-plugin
        thunar-media-tags-plugin
      ];
    });
in
{
  options.ataraxia.programs.default = {
    enable = mkEnableOption "Install some program by default";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bat
      bottom
      fd
      file
      jellyfin-mpv-shim
      jq
      libqalculate
      p7zip
      pinfo
      psmisc
      qalculate-gtk
      qbittorrent
      qimgv
      rename
      ripgrep
      rsync
      thunarFinal
      tldr
      translate-shell
      unrar
      unzip
      xarchiver
      yt-dlp
    ];

    persist.state.directories = [
      ".config/jellyfin-mpv-shim"
      ".config/qalculate"
      ".config/qBittorrent"
      ".config/qimgv"
      ".config/Thunar"
      ".config/xarchiver"
      ".local/share/qalculate"
      ".local/share/qBittorrent"
    ];

    defaultApplications = {
      archive = {
        cmd = getExe pkgs.xarchiver;
        desktop = "xarchiver";
      };
      fm = {
        cmd = "${thunarFinal}/bin/thunar";
        desktop = "thunar";
      };
      image = {
        cmd = getExe pkgs.qimgv;
        desktop = "qimgv";
      };
      torrent = {
        cmd = getExe pkgs.qbittorrent;
        desktop = "qbittorrent";
      };
    };
  };
}
