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
    glib.out
    # gptfdisk
    kitti3
    libqalculate
    lm_sensors
    lnav
    nix-alien
    nixfmt
    nixpkgs-fmt
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
    deadbeef
    discord
    feh
    foliate
    gparted
    jellyfin-media-player
    networkmanagerapplet
    # persepolis
    pinta
    qbittorrent
    qimgv
    # quodlibet
    system-config-printer
    tdesktop
    xarchiver
    youtube-to-mpv
    zathura

    # libsForQt5.networkmanager-qt
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
    schildichat-desktop-wayland
    scrcpy
  ] ++ lib.optionals isGaming [
    # ceserver
    # ckan
    gamescope
    goverlay
    lutris
    obs-studio
    polymc
    reshade-shaders
    (retroarch.override { cores = [ libretro.genesis-plus-gx libretro.dosbox ]; })
    parsec
    protontricks
    vkBasalt
    wine
    winetricks
  ] ++ lib.optionals isLaptop [
    acpi
    seadrive-fuse
  ];
}
