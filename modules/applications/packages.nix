{ pkgs, config, lib, ... }:
with rec {
  inherit (config) device deviceSpecific;
};
with deviceSpecific; {
  programs.adb.enable = true;
  programs.java = {
    enable = true;
    package = if (device == "AMD-Workstation") then pkgs.jdk13 else pkgs.jre;
  };

  home-manager.users.alukard.home.packages = with pkgs; [
    # Utils
    curl
    wget
    rxvt_unicode
    xclip
    pciutils
    usbutils
    nix-prefetch-git
    # vdpauinfo
    # libva-utils
    lm_sensors
    gparted
    neofetch
    # bashmount
    zip
    feh

    # new tools
    tealdeer
    pinfo
    ncdu
    fd
    ripgrep
    lnav
    advance-touch # python3 pip
    exa
    # nomino # 'heavy' rust build
    bpytop
    nnn
    micro
    # cli
    ranger
    youtube-dl
    # wpgtk
    # pywal
    # python27Packages.pygtk # pywal GTK2 reload
    # python2  # pywal GTK2 reload
    # ncmpcpp

    youtube-to-mpv
    wg-conf
    (vivaldi.override { proprietaryCodecs = true; })

    xfce4-14.thunar
    xfce4-14.xfce4-taskmanager
    git-crypt
    keepassxc
    qbittorrent
    vscode
    xarchiver
    tdesktop
    spotifywm
    # spotify-tui
    discord
    pulseeffects
    # quodlibet
    zathura # pdf
  ] ++ lib.optionals (!isVM) [
    libreoffice
    # rust-stable
    # steam
    # steam-run
    # protontricks
    # lutris
    # retroarch
  ] ++ lib.optionals isLaptop [
    # blueman
    # acpi
  ] ++ lib.optionals (device == "AMD-Workstation") [
    # xonar-fp
  ];

}
