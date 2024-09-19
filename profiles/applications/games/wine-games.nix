{ pkgs, config, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.bottles
    pkgs.heroic
    pkgs.osu-lazer-bin
    pkgs.realrtcw
    pkgs.umu-launcher
  ];
  persist.state.homeDirectories = [
    ".config/heroic"
    ".local/share/bottles"
    ".local/share/osu"
    ".local/share/umu"
  ];
}
