{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.ataraxia.lists) sshHostKeys users;

  cfg = config.ataraxia.containers.remnawave;

  sanitizeHost = lib.replaceStrings [ "[" "]" ":" "." " " ] [ "" "" "-" "-" "-" ];
  mkKnownHosts =
    hostKeys:
    lib.pipe hostKeys [
      (lib.mapAttrsToList (
        host: keys:
        lib.imap0 (
          i: publicKey:
          lib.nameValuePair "srs-${sanitizeHost host}-${toString i}" {
            hostNames = [ host ];
            inherit publicKey;
          }
        ) keys
      ))
      lib.concatLists
      lib.listToAttrs
    ];
in
{
  options.ataraxia.containers.remnawave = {
    srs-sync = mkEnableOption "Enable srs-sync .srs rule-sets mirror";
  };

  config = mkIf cfg.srs-sync {
    sops.secrets.srs-sync-env = {
      sopsFile = secretsDir + /${cfg.sopsDir}/remnawave.yaml;
      owner = users.srs-sync.name;
      restartUnits = [ "srs-sync.service" ];
    };
    sops.secrets.srs-sync-ssh-key = {
      sopsFile = secretsDir + /id_deploy.enc;
      format = "binary";
      owner = users.srs-sync.name;
      restartUnits = [ "srs-sync.service" ];
    };
    systemd.services.srs-sync = {
      description = "Mirror sing-box .srs rule-sets to own hosting";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.openssh
        pkgs.gitMinimal
      ];
      environment = {
        FILES = ./files.txt;
        MANIFEST = "/var/lib/srs-sync/sha256.manifest";
        HOME = "/var/lib/srs-sync";
        SSH_KEY = "/run/credentials/srs-sync.service/ssh-key";
        # TODO: path to nix variable
        VPS_DEST = "ataraxia@static.ataraxiadev.com:/srv/static/srs";
        SSH_PORT = "32323";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe pkgs.srs-sync;
        LoadCredential = [
          "ssh-key:${config.sops.secrets.srs-sync-ssh-key.path}"
        ];
        EnvironmentFile = config.sops.secrets.srs-sync-env.path;
        User = users.srs-sync.name;
        StateDirectory = "srs-sync";
        StateDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/srs-sync";
        UMask = "0077";

        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateIPC = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/srs-sync" ];
        ProtectHome = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
      };
    };
    systemd.timers.srs-sync = {
      description = "Hourly .srs mirror sync";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
    programs.ssh.knownHosts = mkKnownHosts sshHostKeys;
    users.users.${users.srs-sync.name} = {
      isSystemUser = true;
      group = users.srs-sync.name;
      uid = users.srs-sync.uid;
      home = "/var/lib/srs-sync";
      createHome = false;
    };
    users.groups.${users.srs-sync.name}.gid = users.srs-sync.gid;
  };
}
