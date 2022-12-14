{ config, ... }: {
  home-manager.users.${config.mainuser} = {
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  persist.derivative.homeDirectories = [ ".cache/nix-index" ];
}