{ pkgs, config, lib, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.alukard.home.packages = with pkgs; [
    # cli
    bat
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
    samba
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
    audacity
    blueman
    # bookworm
    discord
    element-desktop
    feh
    gparted
    keepassxc
    # persepolis
    pinta
    qbittorrent
    qimgv
    quodlibet
    scrcpy
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
    libreoffice
  ] ++ lib.optionals isGaming [
    # ceserver
    # ckan
    gamescope
    goverlay
    multimc
    lutris
    obs-studio
    reshade-shaders
    # (retroarch.override { cores = [ libretro.genesis-plus-gx ]; })
    protontricks
    vkBasalt
    # wine
    # winetricks
  ] ++ lib.optionals isLaptop [
    acpi
  ] ++ lib.optionals (config.device == "AMD-Workstation") [
  ] ++ lib.optionals (enableVirtualisation) [
    virt-manager
  ] ++ lib.optionals (config.virtualisation.docker.enable) [
    docker-compose
  ];

}
