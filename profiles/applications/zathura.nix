{ config, lib, ... }:
let
  home = config.home-manager.users.${config.mainuser};
  zathura-pkg = home.programs.zathura.package;
in{
  defaultApplications = {
    pdf = {
      cmd = lib.getExe zathura-pkg;
      desktop = "zathura";
    };
  };

  home-manager.users.${config.mainuser} = {
    programs.zathura = {
      enable = true;
      extraConfig = ''
        set selection-clipboard clipboard
      '';
      # mappings = {};
      # options = {};
    };
  };
}