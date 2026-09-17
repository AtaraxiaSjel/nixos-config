{
  config,
  lib,
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
  inherit (config.ataraxia.lists) users;

  cfg = config.ataraxia.services.searxng;
  nginx = config.ataraxia.services.nginx;
  domain = "search.ataraxiadev.com";

  disabledEngines = map (x: {
    name = x;
    disabled = true;
  });
  enabledEngines = map (x: {
    name = x;
    disabled = false;
  });
in
{
  options.ataraxia.services.searxng = {
    enable = mkEnableOption "Enable searxng service";
    sopsDir = mkOption {
      type = str;
      default = config.networking.hostName;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.searx-secret = {
      sopsFile = secretsDir + /${cfg.sopsDir}/searx.yaml;
      owner = "searx";
    };
    services.searx = {
      enable = true;
      openFirewall = false;
      configureNginx = false;
      redisCreateLocally = true;
      # Rate limiting
      limiterSettings = {
        real_ip = {
          x_for = 1;
          ipv4_prefix = 32;
          ipv6_prefix = 56;
        };
        botdetection = {
          ip_limit = {
            filter_link_local = true;
            link_token = false;
          };
        };
      };
      # UWSGI configuration
      configureUwsgi = true;
      uwsgiConfig = {
        disable-logging = true;
        socket = "/run/searx/searx.sock";
        chmod-socket = "660";
      };
      settings = {
        general = {
          debug = false;
          instance_name = "SearXNG Instance";
          donation_url = false;
          contact_url = false;
          privacypolicy_url = false;
          enable_metrics = false;
        };
        search = {
          safe_search = 0;
          formats = [
            "html"
            "json"
          ];
        };
        server = {
          base_url = "https://${domain}";
          bind_address = "127.0.0.1";
          secret_key = config.sops.secrets.searx-secret.path;
          limiter = false;
          # public_instance = false;
          image_proxy = true;
          method = "GET";
        };
        outgoing.proxies = {
          "all://" = [ "socks5h://10.10.10.1:10000" ];
        };
        engines =
          enabledEngines [
            "arxiv"
            "crossref"
            "openalex"
            "semantic scholar"
            "brave"
            "duckduckgo"
            "mojeek"
            "wikipedia"
          ]
          ++ disabledEngines [
            "bing"
            "google"
            "startpage"
            "qwant"
          ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          # proxyWebsockets = true;
          extraConfig = ''
            uwsgi_pass unix:${config.services.searx.uwsgiConfig.socket};
          '';
        };
      };
    };

    users.users.searx.uid = users.searx.uid;
    users.groups.searx = {
      gid = users.searx.gid;
      members = [ config.services.nginx.group ];
    };
  };
}
