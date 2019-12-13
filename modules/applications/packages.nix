{ pkgs, config, lib, ... }:
with rec {
  inherit (config) device deviceSpecific;
};
with deviceSpecific;
let
  rust-stable = pkgs.rustChannels.stable.rust.override {
    extensions = [
      "rls-preview"
      "clippy-preview"
      "rustfmt-preview"
    ];
  };
in {
  programs.adb.enable = true;

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

    # mullvad-vpn
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

    (youtube-to-mpv.override { isLaptop = isLaptop; })
    wg-conf
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
    nix-zsh-completions
    qbittorrent
    # vscodium
    vscode
    # vscode-with-extensions
    xarchiver
    tdesktop
    spotifywm
    discord
  ] ++ lib.optionals (!isVM) [
    steam
    steam-run
    protontricks
  ];

}
