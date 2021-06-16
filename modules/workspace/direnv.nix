{ ... }: {
  home-manager.users.alukard = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
        enableFlakes = true;
      };
    };
  };
}