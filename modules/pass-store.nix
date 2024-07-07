{ pkgs, config, lib, ... }:
let
  cfg = config.services.password-store;
  inherit (lib) mkEnableOption mkOption types escapeShellArg mkIf makeBinPath;
in {
  options.services.password-store = {
    enable = mkEnableOption "password-store";
    store = mkOption {
      type = types.path;
      default = "${config.home-manager.users.${config.mainuser}.xdg.dataHome}/password-store";
    };
    gnupgHome = mkOption {
      type = types.path;
      default = "${config.home-manager.users.${config.mainuser}.xdg.dataHome}/gnupg";
    };
    repo = mkOption {
      type = types.str;
    };
    sshKey = mkOption {
      type = types.str;
    };
  };

  config = mkIf (cfg.enable) {
    home-manager.users.${config.mainuser} = {
      systemd.user.services.activate-secrets = {
        Service = {
          Environment = [
            "GIT_SSH_COMMAND='ssh -i ${cfg.sshKey} -o IdentitiesOnly=yes'"
            "PATH=${makeBinPath [ pkgs.git pkgs.openssh ]}"
          ];
          ExecStart = pkgs.writeShellScript "activate-secrets" ''
            set -euo pipefail
            if [ -d "${cfg.store}/.git" ]; then
              git -C "${cfg.store}" pull
            else
              echo "Pulling ${escapeShellArg cfg.repo}"
              git clone ${escapeShellArg cfg.repo} "${cfg.store}"
            fi
          '';
          Type = "oneshot";
        };
        Unit.PartOf = [ "graphical-session-pre.target" ];
        Install.WantedBy = [ "graphical-session-pre.target" ];
      };
      systemd.user.services.pass-store-sync = {
        Service = {
          Environment = [
            "PASSWORD_STORE_DIR=${cfg.store}"
            "GIT_SSH_COMMAND='ssh -i ${cfg.sshKey} -o IdentitiesOnly=yes'"
            "PATH=${with pkgs; makeBinPath [ pass-wayland inotify-tools ]}"
          ];
          ExecStart = pkgs.writeShellScript "pass-store-sync" ''
            set -euo pipefail
            while inotifywait "$PASSWORD_STORE_DIR" -r -e move -e close_write -e create -e delete --exclude .git; do
              sleep 0.1
              pass git add --all
              pass git commit -m "$(date +%F)_$(date +%T)"
              pass git pull --rebase
              pass git push
            done
          '';
        };
        Unit = rec {
          After = [ "activate-secrets.service" ];
          Wants = After;
        };
        Install.WantedBy = [ "graphical-session-pre.target" ];
      };
      programs.password-store = {
        enable = true;
        package = pkgs.pass-wayland;
        settings.PASSWORD_STORE_DIR = cfg.store;
      };
    };
  };
}
