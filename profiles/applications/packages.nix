{ pkgs, config, lib, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [
      # --- cli ---
      comma
      curl
      curlie
      duf
      eza
      fd
      glib.out
      jq
      libqalculate
      lm_sensors
      lnav
      nix-prefetch-git
      nix-prefetch-github
      p7zip
      pciutils
      rclone
      ripgrep
      ripgrep-all
      sd
      tealdeer
      translate-shell
      unrar
      unzip
      usbutils
      zip
      # --- tui ---
      ncdu
      procs
      # --- gui ---
      feh
      qimgv
      xarchiver
      zathura
      xdg-utils
    ] ++ lib.optionals (!(isVM || isISO)) [
      cachix
      ffmpeg.bin
      monero-gui
      nix-tree
      yt-dlp
      # ---- gui ----
      bitwarden
      jellyfin-mpv-shim
      obs-studio
      obs-studio-plugins.obs-vkcapture
      obsidian
      onlyoffice-bin_latest
      pinta
      qbittorrent
      sonixd
      tdesktop
      tidal-dl
      tor-browser-bundle-bin
      ungoogled-chromium
      webcord-vencord
      youtube-to-mpv
    ] ++ lib.optionals isGaming [
      ceserver
      gamescope
      protonhax
      protontricks
      vkBasalt
      # wine
      # winetricks
    ];
  };

  persist.state.homeDirectories = [
    ".config/Bitwarden"
    ".config/chromium"
    ".config/jellyfin-mpv-shim"
    ".config/libreoffice"
    ".config/monero-project"
    ".config/obs-studio"
    ".config/obsidian"
    ".config/pcmanfm"
    ".config/Pinta"
    ".config/qBittorrent"
    ".config/qimgv"
    ".config/rclone"
    ".config/Sonixd"
    ".config/WebCord"
    ".config/xarchiver"
    ".local/share/TelegramDesktop"
    ".local/share/tor-browser"
    ".android"
    ".anydesk"
    ".bitmonero"
    ".monero"
  ];

  persist.state.homeFiles = [
    ".config/.tidal-dl.json"
    ".config/.tidal-dl.token.json"
  ];
}
