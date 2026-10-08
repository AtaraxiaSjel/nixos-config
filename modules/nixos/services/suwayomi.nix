{
  config,
  lib,
  inputs,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool str;
  inherit (config.ataraxia.lists) ports users;

  cfg = config.ataraxia.services.suwayomi;
  suwayomi = config.services.suwayomi-server;
  nginx = config.ataraxia.services.nginx;
  domain = "manga.ataraxiadev.com";
  dataDir = "/srv/suwayomi";
  localDir = "/srv/suwayomi-local";
  suwayomiUser = config.services.suwayomi-server.user;
  suwayomiGroup = config.services.suwayomi-server.group;
in
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.suwayomi-server ];
  disabledModules = [ "services/web-apps/suwayomi-server.nix" ];

  options.ataraxia.services.suwayomi = {
    enable = mkEnableOption "Enable suwayomi service";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
    sopsDir = mkOption {
      type = str;
      default = config.networking.hostName;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.syncyomi-api-key = {
      sopsFile = secretsDir + /${cfg.sopsDir}/syncyomi.yaml;
      owner = suwayomiUser;
    };
    services.suwayomi-server = {
      enable = true;
      user = users.suwayomi.name;
      group = users.suwayomi.name;
      dataDir = dataDir;
      openFirewall = false;
      settings = {
        server = {
          ip = "127.0.0.1";
          port = ports.suwayomi.int;
          initialOpenInBrowserEnabled = false;
          authMode = "none";
          backupTime = "05:00";
          backupTTL = 7;
          downloadAsCbz = true;
          extensionStores = [
            "https://github.com/keiyoushi/extensions/raw/repo/index.pb"
            "https://github.com/Kareadita/tach-extension/raw/repo/index.min.json"
          ];
          excludeUnreadChapters = false;
          localSourcePath = localDir;
          systemTrayEnabled = false;
          flareSolverrEnabled = true;
          flareSolverrUrl = "http://127.0.0.1:${ports.flaresolverr.str}";
          syncYomiEnabled = true;
          syncYomiHost = "http://127.0.0.1:${ports.syncyomi.str}";
          syncInterval = "1h";
          syncYomiApiKeyFile = config.sops.secrets.syncyomi-api-key.path;
        };
      };
    };
    systemd.services.suwayomi-server.serviceConfig.ReadWritePaths = [ localDir ];
    # Pin uid and gid
    users.users.${suwayomiUser}.uid = users.suwayomi.uid;
    users.groups.${suwayomiGroup}.gid = users.suwayomi.gid;

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.suwayomi.str}";
          proxyWebsockets = true;
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${localDir} 0700 ${suwayomi.user} ${suwayomi.group} -"
    ];

    persist.state.directories = [
      dataDir
      localDir
    ];
  };
}
