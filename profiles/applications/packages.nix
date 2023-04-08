{ pkgs, config, lib, inputs, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [
      # --- cli ---
      bat
      comma
      curl
      exa
      fd
      glib.out
      jq
      libqalculate
      lm_sensors
      lnav
      nix-prefetch-git
      p7zip
      pciutils
      ripgrep
      ripgrep-all
      sd
      tealdeer
      translate-shell
      unrar
      unzip
      usbutils
      wget
      zip
      # --- tui ---
      bottom
      micro
      ncdu
      procs
      # --- gui ---
      deadbeef
      feh
      qimgv
      xarchiver
      zathura
      xdg-utils
      # --- awesome-shell ---
      # curlie
      # duf
      # zsh-z
    ] ++ lib.optionals (!(isVM || isISO)) [
      a2ln
      # audacity
      # blueman
      cachix
      ffmpeg.bin
      monero-gui
      nodePackages.peerflix
      nix-tree
      # samba
      yt-dlp
      # ---- gui ----
      bitwarden
      discord
      # foliate
      jellyfin-media-player
      joplin-desktop
      # libreoffice
      obs-studio
      pinta
      qbittorrent
      schildichat-desktop-wayland
      sonixd
      tdesktop
      ungoogled-chromium
      youtube-to-mpv
    ] ++ lib.optionals isGaming [
      ceserver
      gamescope
      # goverlay
      lutris
      # moonlight-qt
      # reshade-shaders
      # (retroarch.override { cores = [ libretro.genesis-plus-gx libretro.dosbox ]; })
      # parsec
      protonhax
      protontricks
      vkBasalt
      wine
      winetricks
    ];

    systemd.user.services.tealdeer-update = {
      Service = {
        ExecStart = "${pkgs.tealdeer}/bin/tldr --update";
        Type = "oneshot";
      };
      Unit.After = [ "network.target" ];
      Install.WantedBy = [ "default.target" ];
    };
  };

  persist.state.homeDirectories = [
    # ".config/audacity"
    ".config/Bitwarden"
    ".config/chromium"
    ".config/deadbeef"
    ".config/discord"
    ".config/jellyfin.org"
    ".config/joplin-desktop"
    ".config/kdeconnect"
    ".config/libreoffice"
    # ".config/looking-glass"
    # ".config/Moonlight Game Streaming Project"
    # ".config/monero-project"
    ".config/obs-studio"
    ".config/pcmanfm"
    # ".config/Pinta"
    ".config/qBittorrent"
    # ".config/qimgv"
    ".config/SchildiChat"
    ".config/Sonixd"
    # ".config/xarchiver"
    ".local/share/TelegramDesktop"
    ".android"
    ".anydesk"
    ".monero"
  ];
}
