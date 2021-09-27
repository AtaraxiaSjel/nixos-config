{ ... }: {
  home-manager.users.alukard = {
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}