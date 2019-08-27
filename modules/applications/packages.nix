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

  ];

  home-manager.users.balsoft.home.packages = with pkgs; [
    nix-zsh-completions
    qbittorrent
    vscodium
    xarchiver
    xfce4-14.xfce4-taskmanager
  ];

}
