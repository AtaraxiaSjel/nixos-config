{ pkgs, config, lib, ... }:
with rec {
  inherit (config) deviceSpecific;
};
with deviceSpecific; {
  # programs.adb.enable = true;

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

    lxqt.pavucontrol-qt
    bibata-cursors
    i3lock-fancy
    # Samba support
    cifs-utils
    # Utils
    nix-prefetch-git
    hdparm
    vdpauinfo
    libva-utils
    lm_sensors
    libnotify
    (youtube-to-mpv.override { isLaptop = isLaptop; })
    # Other
    (vivaldi.override { proprietaryCodecs = true; })
    wget
    gparted
    neofetch
    bashmount
    p7zip
    zip
    ranger
    youtube-dl
    speedcrunch
    feh
    setroot
    maim
    mupdf
  ] ++ lib.optionals isLaptop [
    # Important
    acpi
    light
    powertop
    # Other
    blueman
  ] ++ lib.optionals (!isVM) [
    libreoffice
  ];

  home-manager.users.alukard.home.packages = with pkgs; [
    nix-zsh-completions
    qbittorrent
    vscodium
    xarchiver
    tdesktop
    spotifywm
    discord
  ] ++ lib.optionals (!isVM) [
    steam
    steam-run
  ];

}
