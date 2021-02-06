{ pkgs, config, lib, ... }:
with config.deviceSpecific; {
  programs.adb.enable = true;

  programs.java = {
    enable = true;
    package = if (config.device == "AMD-Workstation") then pkgs.jdk13 else pkgs.jre;
  };

  # Install cdemu for some gaming purposes
  # programs.cdemu = {
  #   enable = true;
  #   image-analyzer = false;
  #   gui = false;
  #   group = "cdrom";
  # };

  home-manager.users.alukard.home.packages = with pkgs; [
    # cli
    advance-touch
    curl
    ddgr
    exa
    fd
    git-crypt
    lm_sensors
    lnav
    neofetch
    nix-prefetch-git
    nix-prefetch-github
    nomino
    # (p7zip.override { enableUnfree = true; })
    p7zip
    pciutils
    pinfo
    ripgrep
    tealdeer
    unzip
    usbutils
    wg-conf
    wget
    xclip
    youtube-dl
    zip
    gptfdisk

    # tui
    bpytop
    micro
    ncdu
    nnn
    ranger

    # gui
    discord
    feh
    gnome3.simple-scan
    gparted
    keepassxc
    pinta
    pulseeffects
    qbittorrent
    spotifywm
    system-config-printer
    tdesktop
    (vivaldi.override { proprietaryCodecs = true; })
    vscode
    xarchiver
    xfce4-14.thunar
    xfce4-14.xfce4-taskmanager
    youtube-to-mpv
    zathura
    # audacity # fixit
    # quodlibet
    spicetify-cli
  ] ++ lib.optionals (!isVM) [
    # rust-stable
    libreoffice
    # Android dev
    androidenv.androidPkgs_9_0.androidsdk
    android-studio
    # scrcpy
  ] ++ lib.optionals isGaming [
    # lutris
    # protontricks
    # retroarch
    steam-run
    (steam.override { withJava = true; })
  ] ++ lib.optionals isLaptop [
    # acpi
    # blueman
  ] ++ lib.optionals (config.device == "AMD-Workstation") [
    # xonar-fp
  ] ++ lib.optionals (enableVirtualisation) [
    virt-manager
  ];

}
