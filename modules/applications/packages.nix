{ pkgs, config, lib, ... }: {
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
  ] ++ lib.optionals config.deviceSpecific.isLaptop [
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
