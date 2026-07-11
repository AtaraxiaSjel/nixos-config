{
  config,
  lib,
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
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.services.suwayomi;
  suwayomi = config.services.suwayomi-server;
  nginx = config.ataraxia.services.nginx;
  domain = "manga.ataraxiadev.com";
in
{
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
      dataDir = "/srv/suwayomi";
      openFirewall = false;
      settings = {
        server = {
          ip = "127.0.0.1";
          port = ports.suwayomi.int;
          basicAuthEnabled = false;
          downloadAsCbz = true;
          extensionRepos = [
            "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
            "https://raw.githubusercontent.com/yuzono/manga-repo/repo/index.min.json"
          ];
          localSourcePath = "/srv/suwayomi-local";
          systemTrayEnabled = false;
        };
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.suwayomi.str}";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /srv/suwayomi-local 0700 ${suwayomi.user} ${suwayomi.group} -"
    ];

    persist.state.directories = [
      suwayomi.dataDir
      suwayomi.settings.server.localSourcePath
    ];
  };
}
