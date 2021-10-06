{ pkgs, config, lib, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  home-manager.users.alukard.home.packages = with pkgs; [
    # cli
    curl
    exa
    fd
    git-filter-repo
    glib.bin # gio
    gptfdisk
    libqalculate
    lm_sensors
    lnav
    manix
    neofetch
    nix-prefetch-git
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
    wget
    xclip
    youtube-dl
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
    spotify-tui

    # gui
    audacity
    blueman
    bookworm
    discord
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
    ceserver
    ckan
    goverlay
    multimc
    lutris
    obs-studio
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
