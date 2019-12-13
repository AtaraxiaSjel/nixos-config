{ pkgs, config, ... }: {
  home-manager.users.alukard.programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}