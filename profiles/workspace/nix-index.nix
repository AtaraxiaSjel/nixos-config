{ config, ... }: {
  home-manager.users.${config.mainuser} = {
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}