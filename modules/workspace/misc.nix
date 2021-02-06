{ pkgs, lib, config, ... }: {

  environment.sessionVariables = config.home-manager.users.alukard.home.sessionVariables // {
    NIX_AUTO_RUN = "1";
  };

  home-manager.users.alukard = {
    xdg.enable = true;

    home.activation."mimeapps-remove" = {
      before = [ "linkGeneration" ];
      after = [ ];
      data = "rm -f /home/alukard/.config/mimeapps.list";
    };

    services.udiskie.enable = true;

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      # enable use_flake support
      stdlib = ''
        use_flake() {
          watch_file flake.nix
          watch_file flake.lock
          eval "$(nix print-dev-env)"
        }
      '';
    };

    news.display = "silent";

    systemd.user.startServices = true;
  };

  home-manager.users.alukard.home.stateVersion = "20.09";

  system.stateVersion = "20.03";
}
