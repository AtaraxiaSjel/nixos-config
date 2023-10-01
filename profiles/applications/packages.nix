{ pkgs, config, lib, inputs, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [
      # --- cli ---
      bat
      comma
      curl
      eza
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
      cachix
      ffmpeg.bin
      monero-gui
      nodePackages.peerflix
      nix-tree
      yt-dlp
      # ---- gui ----
      bitwarden
      # foliate
      jellyfin-media-player
      jellyfin-mpv-shim
      joplin-desktop
      # libreoffice
      obs-studio
      pinta
      qbittorrent
      sonixd
      tdesktop
      tidal-dl
      ungoogled-chromium
      webcord-vencord
      youtube-to-mpv
    ] ++ lib.optionals isGaming [
      ceserver
      gamescope
      moonlight-qt
      protonhax
      protontricks
      vkBasalt
      wine
      winetricks
    ];
  };

  persist.state.homeDirectories = [
    ".config/Bitwarden"
    ".config/chromium"
    ".config/deadbeef"
    ".config/jellyfin-mpv-shim"
    ".config/jellyfin.org"
    ".config/joplin-desktop"
    ".config/kdeconnect"
    ".config/libreoffice"
    ".config/obs-studio"
    ".config/pcmanfm"
    # ".config/Pinta"
    ".config/qBittorrent"
    # ".config/qimgv"
    ".config/Sonixd"
    # ".config/xarchiver"
    ".local/share/jellyfinmediaplayer"
    ".local/share/TelegramDesktop"
    ".android"
    ".anydesk"
    ".monero"
  ];

  persist.state.homeFiles = [
    ".config/.tidal-dl.json"
    ".config/.tidal-dl.token.json"
  ];
}
