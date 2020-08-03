{ pkgs, config, lib, ... }:
with import ../support.nix { inherit lib config; }; {
  options.defaultApplications = lib.mkOption {
    type = lib.types.attrs;
    description = "Preferred applications";
  };
  config = rec {
    defaultApplications = {
      term = {
        cmd = "${pkgs.rxvt_unicode}/bin/urxvt";
        desktop = "urxvt";
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
    home-manager.users.alukard.xdg.configFile."mimeapps.list.home".text =
    with config.defaultApplications;
    let
      apps = builtins.mapAttrs (name: value: "${value.desktop}.desktop;") {
        "text/html" = browser;
        # "image/*" = { desktop = "org.kde.gwenview"; };
        "application/x-bittorrent" = torrent;
        "application/zip" = archive;
        "application/rar" = archive;
        "application/7z" = archive;
        "application/*tar" = archive;
        "application/x-kdenlive" = archive;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        # "x-scheme-handler/mailto" = mail;
        "application/pdf" = pdf;
        # "application/pdf" = { desktop = "org.kde.okular"; };
        # "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
        # text_processor;
        # "application/msword" = text_processor;
        # "application/vnd.oasis.opendocument.text" = text_processor;
        # "text/csv" = spreadsheet;
        # "application/vnd.oasis.opendocument.spreadsheet" = spreadsheet;
        # This actually makes Emacs an editor for everything... XDG is wierd
        "text/plain" = editor;
      };
    in genIni {
      "Default Applications" = apps;
      "Added Associations" = apps;
    };
    home-manager.users.alukard.xdg.configFile."filetypesrc".text = genIni {
      EmbedSettings = {
        "embed-application/*" = false;
        "embed-text/*" = false;
        "embed-text/plain" = false;
      };
    };
    home-manager.users.alukard.home.activation.mimeapps = {
      before = [];
      after = ["linkGeneration"];
      data = ''
        $DRY_RUN_CMD rm -f ~/.config/mimeapps.list
        $DRY_RUN_CMD cp ~/.config/mimeapps.list.home ~/.config/mimeapps.list
      '';
    };
  };
}
