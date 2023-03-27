{ pkgs, config, lib, inputs, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [
      # cli
      a2ln
      bat
      comma
      curl
      exa
      fd
      ffmpeg.bin
      # git-filter-repo
      glib.out
      # gptfdisk
      jq
      libqalculate
      lm_sensors
      lnav
      # nix-alien
      nix-prefetch-git
      nix-index-update
      p7zip
      # (p7zip.override { enableUnfree = true; })
      pciutils
      # pinfo
      ripgrep
      ripgrep-all
      sd
      tealdeer
      translate-shell
      unrar
      unzip
      usbutils
      wget
      yt-dlp
      zip

      # tui
      bottom
      micro
      ncdu
      nix-tree
      procs

      # gui
      bitwarden
      ungoogled-chromium
      deadbeef
      discord
      feh
      foliate
      pinta
      qbittorrent
      qimgv
      system-config-printer
      tdesktop
      xarchiver
      youtube-to-mpv
      zathura

      xdg-utils

      # awesome-shell
      curlie
      duf
      zsh-z
    ] ++ lib.optionals (!(isVM || isISO)) [
      audacity
      blueman
      cachix
      jellyfin-media-player
      joplin-desktop
      libreoffice
      monero-gui
      nodePackages.peerflix
      samba
      schildichat-desktop-wayland
      # scrcpy
      sonixd
    ] ++ lib.optionals isGaming [
      ceserver
      gamescope
      # goverlay
      lutris
      moonlight-qt
      obs-studio
      # reshade-shaders
      # (retroarch.override { cores = [ libretro.genesis-plus-gx libretro.dosbox ]; })
      # parsec
      protonhax
      protontricks
      vkBasalt
      wine
      winetricks
    ] ++ lib.optionals isLaptop [
      acpi
      # seadrive-fuse
    ];
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
    ".config/lutris"
    # ".config/monero-project"
    ".config/obs-studio"
    ".config/pcmanfm"
    # ".config/Pinta"
    ".config/qBittorrent"
    ".config/rclone"
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
