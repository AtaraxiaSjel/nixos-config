{ config, ... }: {
  home-manager.users.${config.mainuser} = {
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
  programs.command-not-found.enable = lib.mkForce false;

  persist.derivative.homeDirectories = [ ".cache/nix-index" ];
}