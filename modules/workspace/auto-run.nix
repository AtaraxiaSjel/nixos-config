{ config, pkgs, lib, ... }: {
  home-manager.users.alukard = {

    programs.command-not-found = {
      enable = true;
      dbPath = ../../misc/programs.sqlite;
    };

  };

  environment.sessionVariables = {
    NIX_AUTO_RUN = "1";
  };
}