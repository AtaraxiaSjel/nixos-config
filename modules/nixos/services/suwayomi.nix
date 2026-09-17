{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool;
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
  };

  config = mkIf cfg.enable {
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
          authMode = "none";
          downloadAsCbz = true;
          extensionRepos = [
            "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
            "https://raw.githubusercontent.com/yuzono/manga-repo/repo/index.min.json"
          ];
          localSourcePath = localDir;
          systemTrayEnabled = false;
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
