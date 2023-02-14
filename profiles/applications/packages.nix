{ pkgs, config, lib, inputs, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.${config.mainuser}.home.packages = with pkgs; [
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
    jellyfin-media-player
    joplin-desktop
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
    libreoffice
    nodePackages.peerflix
    samba
    schildichat-desktop-wayland
    scrcpy
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
}
