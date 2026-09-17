{
  config,
  lib,
  pkgs,
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
  inherit (config.virtualisation.quadlet) networks;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.containers.media-stack;
  nginx = config.ataraxia.services.nginx;
  nas-path = "/media/nas/media-stack";
  domain = "lampa.ataraxiadev.com";

  skipModules = [
    # дефолты base.conf
    "Catalog"
    "DLNA"
    "Tracks"
    "Transcoding"
    "WebLog"
    "CacheMedia"
    "ForkPlayerXML"
    "MsxNative"
    "Potok"
    "TelegramAuth"
    "TelegramAuthBot"
    # Payed
    "Kodik"
    "VoKino"
    "GetsTV"
    "SakhTV"
    "IptvOnline"
    "KinoPub"
    "Alloha"
    "iRemux"
    # 18+
    "SISI"
    "NextHUB"
    "BongaCams"
    "Chaturbate"
    "Ebalovo"
    "Eporner"
    "HQporner"
    "PornHub"
    "Porntrex"
    "Runetki"
    "Spankbang"
    "Tizam"
    "Xhamster"
    "Xnxx"
    "Xvideos"
    "XvideosRED"
  ];

  lampacInitConf = pkgs.writeText "lampac-init.conf" (
    builtins.toJSON {
      listen = {
        ip = "0.0.0.0";
        port = 9118;
        scheme = "http";
        localhost = "127.0.0.1";
      };
      lowMemoryMode = true;
      chromium.enable = true;
      firefox.enable = false;
      gst.enable = true;
      openstat.enable = false;
      online = {
        name = "Lampac";
        version = true;
        btn_priority_forced = true;
      };
      LampaWeb = {
        autoupdate = true;
        widgets.samsung = false;
        widgets.lg = false;
        initPlugins = {
          online = true;
          torrserver = true;
          timecode = true;
          tmdbProxy = true;
          cubProxy = true;
          jacred = true;
          sisi = false;
          pirate_store = false;
        };
        customPlugins = [
          {
            url = "https://lampa.ataraxiadev.com/gst.js";
            status = 1;
          }
        ];
      };
      BaseModule.SkipModules = skipModules;
    }
  );
in
{
  options.ataraxia.containers.lampac = {
    enable = mkEnableOption "Enable lampac container";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet.containers.lampac = {
      autoStart = true;
      containerConfig = {
        # updater: strategy=semver-best, semver=>=1.0,<2.0
        # Tags: v1.50.1
        image = "ghcr.io/lampac-nextgen/lampac@sha256:593543591f3a9874b7bfceb3a65f24275931a6ac70e18e9d436dedebdff4d8df";
        shmSize = "1024M";
        networks = [ networks.br-services.ref ];
        publishPorts = [ "127.0.0.1:${ports.lampac.str}:9118/tcp" ];
        volumes = [
          "${lampacInitConf}:/lampac/init.conf:ro"
          # "${nas-path}/configs/lampac/init.conf:/lampac/init.conf"
          "${nas-path}/configs/lampac/ts:/lampac/data/ts"
          "${nas-path}/configs/lampac/cache:/lampac/cache"
          "${nas-path}/configs/lampac/database:/lampac/database"
          "${nas-path}/configs/lampac/wwwroot:/lampac/wwwroot"
        ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.lampac.str}";
          proxyWebsockets = true;
          extraConfig = ''
            allow 127.0.0.1/32;
            allow 100.64.0.0/16;
            allow 10.10.10.0/24;
            allow fd7a:115c:a1e0::/64;
            deny all;

            proxy_buffering off;
          '';
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d ${nas-path}/configs/lampac          0755 1000 100 -"
      "d ${nas-path}/configs/lampac/ts       0755 1000 100 -"
      "d ${nas-path}/configs/lampac/cache    0755 1000 100 -"
      "d ${nas-path}/configs/lampac/database 0755 1000 100 -"
      "d ${nas-path}/configs/lampac/wwwroot  0755 1000 100 -"
    ];
  };
}
