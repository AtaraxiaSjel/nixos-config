{ pkgs, config, lib, ... }:
with rec {
  inherit (config) device deviceSpecific;
};
with deviceSpecific;
let
  rust-stable = pkgs.latest.rustChannels.stable.rust.override {
    extensions = [
      "rls-preview"
      "clippy-preview"
      "rustfmt-preview"
    ];
  };
in {
  programs.adb.enable = true;
  programs.java = {
    enable = true;
    package = if (device == "AMD-Workstation") then pkgs.jdk13 else pkgs.jre;
  };

  environment.systemPackages = with pkgs; [
    # Important
    rxvt_unicode
    curl
    xfce4-14.thunar
    xfce4-14.xfce4-taskmanager
    xclip
    bc
    sysstat
    xdotool
    niv

    lxqt.pavucontrol-qt
    bibata-cursors
    i3lock-fancy-rapid

    keepassxc
    git-crypt
    # Samba support
    cifs-utils
    # Utils
    pciutils
    usbutils
    nix-prefetch-git
    hdparm
    vdpauinfo
    libva-utils
    lm_sensors
    libnotify
    tree
    iperf

    # Other
    (youtube-to-mpv.override { isLaptop = isLaptop; })
    wg-conf
    (vivaldi.override { proprietaryCodecs = true; })
    wget
    gparted
    neofetch
    bashmount
    zip
    ranger
    youtube-dl
    lua
    feh
    maim
    ncmpcpp

    pywal
    python27Packages.pygtk
    python2
  ] ++ lib.optionals isLaptop [
    # Important
    acpi
    light
    powertop
    # Other
    blueman
  ] ++ lib.optionals (!isVM) [
    libreoffice
    # rust-stable
  ] ++ lib.optionals (device == "AMD-Workstation") [
    xonar-fp
  ];

  home-manager.users.alukard.home.packages = with pkgs; [
    qbittorrent
    vscode
    xarchiver
    tdesktop
    spotifywm
    spotify-tui
    discord
    pulseeffects
    # quodlibet
    zathura
  ] ++ lib.optionals (!isVM) [
    # steam
    # steam-run
    # protontricks
    # lutris
    # retroarch
  ] ++ lib.optionals (enableVirtualisation) [
    docker-compose
  ];

}
