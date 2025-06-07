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
    with pkgs.xfce;
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
      libqalculate
      p7zip
      pinfo
      qalculate-gtk
      qbittorrent
      qimgv
      ripgrep
      rsync
      thunarFinal
      tldr
      translate-shell
      unrar
    ];

    persist.state.directories = [
      ".config/qalculate"
      ".config/qBittorrent"
      ".config/qimgv"
      ".config/Thunar"
      ".config/xarchiver"
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
