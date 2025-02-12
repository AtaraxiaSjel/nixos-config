{ pkgs, config, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.bottles
    pkgs.heroic
    pkgs.lutris
    pkgs.osu-lazer-bin
    pkgs.protonup-qt
    pkgs.realrtcw
    # pkgs.umu-launcher
    pkgs.wine
  ];
  persist.state.homeDirectories = [
    ".config/heroic"
    ".local/share/bottles"
    ".local/share/lutris"
    ".local/share/osu"
    ".local/share/reshade"
    ".local/share/umu"
  ];
}
