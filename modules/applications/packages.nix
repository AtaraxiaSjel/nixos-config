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

    lxqt.pavucontrol-qt
    git
    # Samba support
    cifs-utils
    # Utils
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
    tdesktop
    spotifywm
    youtube-dl
  ] ++ lib.optionals isLaptop [
    # Important
    acpi
    light
  ];

  home-manager.users.alukard.home.packages = with pkgs; [
    nix-zsh-completions
    qbittorrent
    vscodium
    xarchiver
  ];

}
