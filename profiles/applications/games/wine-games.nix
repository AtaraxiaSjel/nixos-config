{ pkgs, config, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.bottles
    pkgs.osu-lazer-bin
    pkgs.realrtcw
  ];
  persist.state.homeDirectories = [
    ".local/share/bottles"
    ".local/share/osu"
  ];
}
