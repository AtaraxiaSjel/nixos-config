{ pkgs, config, lib, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.alukard.home.packages = with pkgs; [
    # cli
    _7zz
    advance-touch
    curl
    ddgr
    exa
    exfat-utils
    fd
    git-crypt
    git-filter-repo
    glib.bin # gio
    gptfdisk
    libqalculate
    lm_sensors
    lnav
    manix
    neofetch
    nix-prefetch-git
    nix-prefetch-github
    nomino
    p7zip
    # (p7zip.override { enableUnfree = true; })
    pciutils
    pinfo
    ripgrep
    ripgrep-all
    samba
    sd
    tealdeer
    unzip
    usbutils
    wg-conf
    wget
    xclip
    youtube-dl
    zip

    # tui
    bottom
    bpytop
    # gdu
    micro
    ncdu
    nix-tree
    nnn
    procs
    ranger
    spotify-tui

    # gui
    audacity # fixit
    blueman
    bookworm
    discord
    easyeffects
    feh
    gnome.eog
    gparted
    keepassxc
    persepolis
    pinta
    qbittorrent
    quodlibet
    scrcpy
    spotifywm
    system-config-printer
    tdesktop
    xarchiver
    xfce4-14.thunar
    xfce4-14.xfce4-taskmanager
    youtube-to-mpv
    zathura
    zoom-us
  ] ++ lib.optionals (!(isVM || isISO)) [
    libreoffice
  ] ++ lib.optionals isGaming [
    lutris
    mangohud
    obs-studio
    wine
    winetricks
  ] ++ lib.optionals isLaptop [
    acpi
  ] ++ lib.optionals (config.device == "AMD-Workstation") [
    multimc
  ] ++ lib.optionals (enableVirtualisation) [
    virt-manager
  ];

}
