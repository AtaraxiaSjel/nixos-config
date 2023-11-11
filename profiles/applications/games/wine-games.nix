{ pkgs, lib, config, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.lutris pkgs.bottles
    pkgs.osu-lazer-bin
    pkgs.realrtcw
  ];
  persist.state.homeDirectories = [
    ".config/lutris"
    ".local/share/lutris"
    ".local/share/bottles"
    ".local/share/osu"
  ];
}
