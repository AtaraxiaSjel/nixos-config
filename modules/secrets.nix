{ pkgs, config, lib, inputs, ... }:
with lib;
with types;
let
  password-store = config.secretsConfig.password-store;
  secret = { name, ... }: {
    options = {
      encrypted = mkOption {
        type = path;
        default = "${password-store}/${name}.gpg";
      };
      decrypted = mkOption {
        type = path;
        default = "/var/secrets/${name}";
      };
      decrypt = mkOption {
        default = pkgs.writeShellScript "gpg-decrypt" ''
          set -euo pipefail
          export GNUPGHOME=${config.secretsConfig.gnupgHome}
          export GPG_TTY="$(tty)"
          ${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye 1>&2
          ${pkgs.gnupg}/bin/gpg --batch --no-tty --decrypt
        '';
      };
      user = mkOption {
        type = str;
        default = "alukard";
      };
      owner = mkOption {
        type = str;
        default = "root:root";
      };
      permissions = mkOption {
        type = lib.types.addCheck lib.types.str
          (perm: !isNull (builtins.match "[0-7]{3}" perm));
        default = "400";
      };
      services = mkOption {
        type = listOf str;
        default = [ "${name}" ];
      };
      __toString = mkOption {
        readOnly = true;
        default = s: s.decrypted;
      };
    };
  };

  activate-secrets = pkgs.writeShellScriptBin "activate-secrets" ''
    set -euo pipefail
    export PATH="${with pkgs; lib.makeBinPath [ openssh gnupg git coreutils ]}:/run/wrappers/bin/:$PATH"
    export SHELL=${pkgs.runtimeShell}
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    if [ -d "${password-store}/.git" ]; then
      cd "${password-store}"; git pull
    else
      echo "${lib.escapeShellArg config.secretsConfig.repo}"
      git clone ${
        lib.escapeShellArg config.secretsConfig.repo
      } "${password-store}"
    fi
    cat ${password-store}/spotify.gpg | ${pkgs.gnupg}/bin/gpg --decrypt > /dev/null
    [ ! -z "${allServices}" ] && sudo systemctl restart ${allServices}
  '';

  decrypt = name: cfg:
    with cfg; {
      "${name}-secrets" = rec {

        wantedBy = [ "multi-user.target" ];
        requires = [ "user@1000.service" ];
        after = requires;

        preStart = ''
          stat '${encrypted}'
          mkdir -p '${builtins.dirOf decrypted}'
        '';

        script = ''
          if cat '${encrypted}' | /run/wrappers/bin/sudo -u ${user} ${cfg.decrypt} > '${decrypted}.tmp'; then
            mv -f '${decrypted}.tmp' '${decrypted}'
            chown '${owner}' '${decrypted}'
            chmod '${permissions}' '${decrypted}'
          else
            echo "Failed to decrypt the secret"
            rm '${decrypted}.tmp'
            if [[ -f '${decrypted}' ]]; then
              echo "The decrypted file exists anyways, not failing"
              exit 0
            else
              exit 1
            fi
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
      };
    };

  addDependencies = name: cfg:
    with cfg;
    genAttrs services (service: rec {
      requires = [ "${name}-secrets.service" ];
      after = requires;
      bindsTo = requires;
    });

  mkServices = name: cfg: [ (decrypt name cfg) (addDependencies name cfg) ];

  allServices = toString (map (name: "${name}-envsubst.service")
    (builtins.attrNames config.secrets-envsubst)
    ++ map (name: "${name}-secrets.service")
    (builtins.attrNames config.secrets));
in {
  options.secrets = lib.mkOption {
    type = attrsOf (submodule secret);
    default = { };
  };

  options.secretsConfig = {
    password-store = lib.mkOption {
      type = lib.types.path;
      default = "${config.home-manager.users.alukard.xdg.dataHome}/password-store";
    };
    gnupgHome = lib.mkOption {
      type = lib.types.path;
      default = "${config.home-manager.users.alukard.xdg.dataHome}/gnupg";
    };
    repo = lib.mkOption {
      type = str;
      default = "gitea@code.ataraxiadev.com:AtaraxiaDev/pass.git";
    };
  };

  config.systemd.services =
    mkMerge (concatLists (mapAttrsToList mkServices config.secrets));

  config.security.sudo.extraRules = [{
    users = [ "alukard" ];
    commands = [{
      command = "/run/current-system/sw/bin/systemctl restart ${allServices}";
      options = [ "NOPASSWD" ];
    }];
  }];

  config.home-manager.users.alukard = {
    systemd.user.services.activate-secrets = {
      Service = {
        ExecStart = "${activate-secrets}/bin/activate-secrets";
        Type = "oneshot";
      };
      Unit = {
        PartOf = [ "graphical-session-pre.target" ];
      };
      Install.WantedBy = [ "graphical-session-pre.target" ];
    };
    systemd.user.services.pass-store-sync = {
      Service = {
        Environment = [
          "PASSWORD_STORE_DIR=${password-store}"
          "PATH=${with pkgs; lib.makeBinPath [ pass inotify-tools gnupg ]}"
        ];
        ExecStart = toString (pkgs.writeShellScript "pass-store-sync" ''
          export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
          while inotifywait "$PASSWORD_STORE_DIR" -r -e move -e close_write -e create -e delete --exclude .git; do
            sleep 0.1
            pass git add --all
            pass git commit -m "$(date +%F)_$(date +%T)"
            pass git pull --rebase
            pass git push
          done
        '');
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
      settings.PASSWORD_STORE_DIR = password-store;
    };
  };
}