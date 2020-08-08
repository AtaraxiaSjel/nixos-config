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
    curl
    wget
    cifs-utils
  ] ++ lib.optionals isLaptop [
    # acpi
    #
  ] ++ lib.optionals (!isVM) [
    # rust-stable
  ] ++ lib.optionals (device == "AMD-Workstation") [
    xonar-fp
  ];

  home-manager.users.alukard.home.packages = with pkgs; [
    # Utils
    rxvt_unicode
    xclip
    pciutils
    usbutils
    nix-prefetch-git
    vdpauinfo
    libva-utils
    lm_sensors
    libnotify
    gparted
    neofetch
    bashmount
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
    nomino # rust build
    bpytop
    nnn
    # vimv
    # cli
    ranger
    youtube-dl
    pywal
    # python27Packages.pygtk
    # python2
    # ncmpcpp

    (youtube-to-mpv.override { isLaptop = isLaptop; })
    wg-conf
    (vivaldi.override { proprietaryCodecs = true; })

    xfce4-14.thunar
    xfce4-14.xfce4-taskmanager
    i3lock-fancy-rapid
    bibata-cursors
    git-crypt
    keepassxc
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
    libreoffice
    # steam
    # steam-run
    # protontricks
    # lutris
    # retroarch
  ] ++ lib.optionals isLaptop [
    # blueman
  ] ++ lib.optionals (enableVirtualisation) [
    docker-compose
  ];

}
