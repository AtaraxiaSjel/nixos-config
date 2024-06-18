{ config, ... }: {
  home-manager.users.${config.mainuser}.programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };

  persist.state.homeDirectories = [ ".local/share/direnv" ];
}