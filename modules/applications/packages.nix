{ pkgs, config, lib, ... }: {
  # programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    (vivaldi.override { proprietaryCodecs = true; })
    rxvt_unicode
    wget
    curl
    gparted
    neofetch
    pavucontrol
    bashmount
    p7zip
    zip
    ranger
    xfce4-14.thunar
    xfce4-14.xfce4-taskmanager
    xclip
    git
  ];

  home-manager.users.alukard.home.packages = with pkgs; [
    nix-zsh-completions
    qbittorrent
    vscodium
    xarchiver
  ];

}
