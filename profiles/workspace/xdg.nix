{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    xdg.enable = true;
    xdg.userDirs.enable = true;
  };

  environment.sessionVariables = { DE = "generic"; };

  systemd.user.services.cleanup-home-dirs = let
    home-conf = config.home-manager.users.${config.mainuser};
    days = "30";
    folders = map (x: home-conf.home.homeDirectory + "/" + x) [ "Downloads" ];
  in {
    serviceConfig.Type = "oneshot";
    script = ''
      ${builtins.concatStringsSep "\n" (map (x:
        "find ${
          lib.escapeShellArg x
        } -mtime +${days} -exec rm -rv {} + -depth;")
        folders)}
    '';
    wantedBy = [ "default.target" ];
  };

  persist.state.homeDirectories =
    [ "Books" "Documents" "Downloads" "Music" "Pictures" "Videos" ];
}
