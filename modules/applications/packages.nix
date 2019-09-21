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

    lxqt.pavucontrol-qt
    git
    # Samba support
    cifs-utils
    # Utils
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
    libreoffice
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
  ];

  home-manager.users.alukard.home.packages = with pkgs; [
    steam
    steam-run

    nix-zsh-completions
    qbittorrent
    vscodium
    xarchiver
    tdesktop
    spotifywm
    discord
  ];

}
