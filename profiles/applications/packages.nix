{ pkgs, config, lib, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.alukard.home.packages = with pkgs; [
    # cli
    bat
    comma
    curl
    exa
    fd
    ffmpeg.bin
    # git-filter-repo
    glib
    # gptfdisk
    kitti3
    libqalculate
    lm_sensors
    lnav
    nix-alien
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
    # tidal-dl
    unzip
    usbutils
    wget
    yt-dlp
    zip

    # tui
    bottom
    bpytop
    micro
    ncdu
    nix-tree
    nnn
    procs
    ranger

    # gui
    bitwarden
    discord
    feh
    foliate
    gparted
    jellyfin-media-player
    parsec
    # persepolis
    pinta
    qbittorrent
    qimgv
    quodlibet
    schildichat-desktop-wayland
    system-config-printer
    tdesktop
    xarchiver
    youtube-to-mpv
    zathura

    # libsForQt5.networkmanager-qt
    # networkmanagerapplet
    xdg-utils

    # awesome-shell
    curlie
    duf
    zsh-z
  ] ++ lib.optionals (!(isVM || isISO)) [
    audacity
    blueman
    libreoffice
    nodePackages.peerflix
    samba
    scrcpy
  ] ++ lib.optionals isGaming [
    # ceserver
    # ckan
    goverlay
    lutris
    obs-studio
    polymc
    reshade-shaders
    (retroarch.override { cores = [ libretro.genesis-plus-gx libretro.dosbox ]; })
    protontricks
    vkBasalt
  ] ++ lib.optionals isLaptop [
    acpi
    seadrive-fuse
  ];
}
