{ config, pkgs, lib, ... }:
let
  dirsToClean = [
    "Downloads"
  ];
  olderThanDays = "14";
in {
  home-manager.users.${config.mainuser} = {
    xdg.enable = true;
    xdg.userDirs.enable = true;
  };

  environment.sessionVariables = { DE = "generic"; };

  systemd.user.services.cleanup-home-dirs = let
    home-conf = config.home-manager.users.${config.mainuser};
    directories = map (x: home-conf.home.homeDirectory + "/" + x) dirsToClean;
  in {
    serviceConfig.Type = "oneshot";
    script = ''
      ${builtins.concatStringsSep "\n" (map (x:
        "find ${
          lib.escapeShellArg x
        } -mtime +${olderThanDays} -exec rm -rv {} + -depth;")
        directories)}
    '';
    wantedBy = [ "default.target" ];
  };

  persist.state.homeDirectories =
    [ "Books" "Documents" "Downloads" "Music" "Pictures" "Videos" ];
}
