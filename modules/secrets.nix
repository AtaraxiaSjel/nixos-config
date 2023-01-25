{ pkgs, config, lib, inputs, ... }:
with lib;
with types;
let
  password-store = config.secretsConfig.password-store;
  password-store-relative = removePrefix config.home-manager.users.${config.mainuser}.home.homeDirectory password-store;
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
        default = config.mainuser;
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
    PATH="${with pkgs; lib.makeBinPath [ openssh gnupg coreutils ]}:$PATH"
    export SSH_AUTH_SOCK="$1"
    export GNUPGHOME=${config.secretsConfig.gnupgHome}
    if [ -d "${password-store}/.git" ]; then
      ${pkgs.git}/bin/git -C "${password-store}" pull
    else
      echo "${lib.escapeShellArg config.secretsConfig.repo}"
      ${pkgs.git}/bin/git clone ${
        lib.escapeShellArg config.secretsConfig.repo
      } "${password-store}"
    fi
    cat ${password-store}/ssh-builder.gpg | ${pkgs.gnupg}/bin/gpg --decrypt > /dev/null
    [ ! -z "${allServices}" ] && /run/wrappers/bin/sudo systemctl restart ${allServices}
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
          if cat '${encrypted}' | /run/wrappers/bin/doas -u ${user} ${cfg.decrypt} > '${decrypted}.tmp'; then
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

  allServicesMap = (map (name: "${name}-envsubst.service")
    (builtins.attrNames config.secrets-envsubst)
    ++ map (name: "${name}-secrets.service")
    (builtins.attrNames config.secrets));

  allServices = toString allServicesMap;

  # https://github.com/nix-community/home-manager/blob/a993eac1065c6ce63a8d724b7bccf624d0e91ca2/modules/services/gpg-agent.nix#L22
  home-conf = config.home-manager.users.${config.mainuser};
  homedir = home-conf.programs.gpg.homedir;
  gpgconf = dir: let
    hash = substring 0 24 (hexStringToBase32 (builtins.hashString "sha1" homedir));
  in if homedir == "${home-conf.home.homeDirectory}/.gnupg" then
    "%t/gnupg/${dir}"
  else
    "%t/gnupg/d.${hash}/${dir}";
  hexStringToBase32 = with lib; let
    mod = a: b: a - a / b * b;
    pow2 = elemAt [ 1 2 4 8 16 32 64 128 256 ];
    splitChars = s: init (tail (splitString "" s));

    base32Alphabet = splitChars "ybndrfg8ejkmcpqxot1uwisza345h769";
    hexToIntTable = listToAttrs (genList (x: {
      name = toLower (toHexString x);
      value = x;
    }) 16);

    initState = {
      ret = "";
      buf = 0;
      bufBits = 0;
    };
    go = { ret, buf, bufBits }:
      hex:
      let
        buf' = buf * pow2 4 + hexToIntTable.${hex};
        bufBits' = bufBits + 4;
        extraBits = bufBits' - 5;
      in if bufBits >= 5 then {
        ret = ret + elemAt base32Alphabet (buf' / pow2 extraBits);
        buf = mod buf' (pow2 extraBits);
        bufBits = bufBits' - 5;
      } else {
        ret = ret;
        buf = buf';
        bufBits = bufBits';
      };
  in hexString: (foldl' go initState (splitChars hexString)).ret;
in {
  options.secrets = lib.mkOption {
    type = attrsOf (submodule secret);
    default = { };
  };

  options.secretsConfig = {
    password-store = lib.mkOption {
      type = lib.types.path;
      default = "${config.home-manager.users.${config.mainuser}.xdg.dataHome}/password-store";
    };
    gnupgHome = lib.mkOption {
      type = lib.types.path;
      default = "${config.home-manager.users.${config.mainuser}.xdg.dataHome}/gnupg";
    };
    repo = lib.mkOption {
      type = str;
      default = "gitea@code.ataraxiadev.com:AtaraxiaDev/pass.git";
    };
  };

  config.systemd.services =
    mkMerge (concatLists (mapAttrsToList mkServices config.secrets));

  config.security.doas.extraRules = [{
    users = [ config.mainuser ];
    noPass = true;
    keepEnv = true;
    cmd = "/run/current-system/sw/bin/systemctl";
    args = [ "restart" ] ++ allServicesMap;
  }];

  config.security.sudo.extraRules = [{
    users = [ config.mainuser ];
    commands = [{
      command = "/run/current-system/sw/bin/systemctl";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }];

  config.persist.derivative.directories = [ "/var/secrets" ];
  config.persist.derivative.homeDirectories = [{
    directory = password-store-relative;
    method = "symlink";
  }];

  config.home-manager.users.${config.mainuser} = {
    systemd.user.services.activate-secrets = let
      ssh-agent = gpgconf "S.gpg-agent.ssh";
    in {
      Service = {
        ExecStart = "${activate-secrets}/bin/activate-secrets '${ssh-agent}'";
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