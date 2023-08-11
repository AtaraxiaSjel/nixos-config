{ pkgs, lib, config, ... }: {
  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.lutris pkgs.bottles
  ];
  persist.state.homeDirectories = [
    ".config/lutris"
    ".local/share/lutris"
    ".local/share/bottles"
  ];
}
