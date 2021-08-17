{ pkgs, config, lib, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  # programs.java = {
  #   enable = true;
  #   package = if (config.device == "AMD-Workstation") then pkgs.jdk13 else pkgs.jre;
  # };

  # Install cdemu for some gaming purposes
  # programs.cdemu = {
  #   enable = true;
  #   image-analyzer = false;
  #   gui = false;
  #   group = "cdrom";
  # };

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
    nnn
    procs
    ranger
    spotify-tui

    # gui
    audacity # fixit
    blueman
    bookworm
    discord
    feh
    gnome.eog
    gparted
    keepassxc
    pinta
    easyeffects
    qbittorrent
    quodlibet
    spotifywm
    system-config-printer
    tdesktop
    vscode
    xarchiver
    xfce4-14.thunar
    xfce4-14.xfce4-taskmanager
    youtube-to-mpv
    zathura

    # misc
    # i3status-rust
  ] ++ lib.optionals (!(isVM || isISO)) [
    # rust-stable
    libreoffice
  ] ++ lib.optionals isGaming [
    lutris
    protontricks
    # retroarch
    # (steam.override { withJava = true; })
    # steam-run
    wine
    winetricks
  ] ++ lib.optionals isLaptop [
    acpi
  ] ++ lib.optionals (config.device == "AMD-Workstation") [
    multimc
    # xonar-fp
    # Android dev
    # androidenv.androidPkgs_9_0.androidsdk
    # android-studio
    # scrcpy
  ] ++ lib.optionals (enableVirtualisation) [
    virt-manager
  ];

}
