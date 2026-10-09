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
  inherit (lib.types) bool str;
  inherit (config.ataraxia.lists) ports users;
  inherit (config.virtualisation.quadlet) networks;

  cfg = config.ataraxia.containers.garage-webui;
  nginx = config.ataraxia.services.nginx;
  domain = "s3webui.ataraxiadev.com";
in
{
  options.ataraxia.containers.garage-webui = {
    enable = mkEnableOption "Enable garage-webui container";
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
    sops.templates.garage-webui-env = {
      # sopsFile = secretsDir + /${cfg.sopsDir}/garage.yaml;
      content = "API_ADMIN_KEY=${config.sops.placeholder.garage-admin-token}";
      restartUnits = [ "garage-webui.service" ];
    };

    virtualisation.quadlet.containers.garage-webui = {
      autoStart = true;
      containerConfig = {
        addHosts = [ "host.containers.internal:host-gateway" ];
        user = "${users.garage.uidStr}:${users.garage.gidStr}";
        image = "docker.io/genebit/garage-webui@sha256:70bad27066a1095b990986e26b4c1c187a05ae2b3be0efb3970fb684836efe00";
        environments = {
          HOST = "0.0.0.0";
          PORT = ports.garage-webui.str;
          API_BASE_URL = "http://host.containers.internal:${ports.garage-api.str}";
          S3_ENDPOINT_URL = "http://host.containers.internal:${ports.garage-s3.str}";
          S3_REGION = "garage";
          # Scratch image has no /tmp.
          TMPDIR = "/data/tmp";
        };
        environmentFiles = [ config.sops.templates.garage-webui-env.path ];
        # healthCmd = "CMD /bin/curl --fail --silent http://127.0.0.1:${ports.garage-webui.str}";
        # healthInterval = "30s";
        # healthRetries = 3;
        # healthStartPeriod = "10s";
        # healthTimeout = "5s";
        readOnly = true;
        networks = [ networks.br-services.ref ];
        publishPorts = [ "127.0.0.1:${ports.garage-webui.str}:${ports.garage-webui.str}/tcp" ];
        volumes = [ "/srv/garage-webui/data:/data" ];
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.garage-webui.str}";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 0;
            proxy_request_buffering off;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;

            allow 127.0.0.1/32;
            allow 100.64.0.0/16;
            allow 10.10.10.0/24;
            allow fd7a:115c:a1e0::/64;
            deny all;

            auth_request /tinyauth;
            auth_request_set $redirection_url $upstream_http_x_tinyauth_location;
            error_page 401 403 =302 $redirection_url;
          '';
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /srv/garage-webui 0700 ${users.garage.uidStr} ${users.garage.gidStr} -"
      "d /srv/garage-webui/data 0700 ${users.garage.uidStr} ${users.garage.gidStr} -"
    ];

    persist.state.directories = [ "/srv/garage-webui/data" ];
  };
}
