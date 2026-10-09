{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool str;
  inherit (config.ataraxia.lists) ports users;

  cfg = config.ataraxia.services.garage;
  nginx = config.ataraxia.services.nginx;
  sopsDefaults = {
    sopsFile = secretsDir + /${cfg.sopsDir}/garage.yaml;
    owner = garage-user;
    restartUnits = [ "garage.service" ];
  };

  domain-s3 = "s3.ataraxiadev.com";
  domain-api = "s3api.ataraxiadev.com";
  # domain-web = "s3web.ataraxiadev.com";

  garage-user = "garage";
  garage-group = "garage";
  data_dir = config.services.garage.settings.data_dir;
  metadata_dir = config.services.garage.settings.metadata_dir;

  internalAcl = ''
    allow 127.0.0.1/32;
    allow 100.64.0.0/16;
    allow 10.10.10.0/24;
    allow fd7a:115c:a1e0::/64;
    deny all;
  '';

  s3ProxySettings = {
    useACMEHost = mkForce domain-s3;
    kTLS = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${ports.garage-s3.str}";
      extraConfig = ''
        client_max_body_size 0;
        proxy_max_temp_file_size 0;
        proxy_busy_buffers_size 1024k;
        proxy_buffers 32 1024k;
        proxy_buffer_size 1024k;
        proxy_read_timeout 86400;
      '';
    };
    # locations."/" = {
    #   proxyPass = "http://127.0.0.1:${ports.garage-s3.str}";
    #   recommendedProxySettings = false;
    #   extraConfig = ''
    #     proxy_http_version 1.1;
    #     proxy_set_header Connection "";
    #     proxy_set_header Host $http_host;
    #     proxy_set_header X-Real-IP $remote_addr;
    #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #     proxy_set_header X-Forwarded-Proto $scheme;
    #     proxy_set_header X-Forwarded-Host $host;
    #     proxy_redirect off;

    #     proxy_max_temp_file_size 0;
    #     proxy_busy_buffers_size 1024k;
    #     proxy_buffers 32 1024k;
    #     proxy_buffer_size 1024k;
    #     proxy_read_timeout 86400;
    #   '';
    # };
  };
in
{
  options.ataraxia.services.garage = {
    enable = mkEnableOption "Enable garage service";
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
    sops.secrets.garage-rpc-token = sopsDefaults;
    sops.secrets.garage-admin-token = sopsDefaults;
    sops.secrets.garage-metrics-token = sopsDefaults;

    services.garage = {
      enable = true;
      package = pkgs.garage_2;
      extraEnvironment = {
        GARAGE_RPC_SECRET_FILE = config.sops.secrets.garage-rpc-token.path;
        GARAGE_ADMIN_TOKEN_FILE = config.sops.secrets.garage-admin-token.path;
        GARAGE_METRICS_TOKEN_FILE = config.sops.secrets.garage-metrics-token.path;
      };
      # environmentFile = null;
      logLevel = "info";
      settings = {
        db_engine = "sqlite";
        data_dir = [
          {
            path = "/srv/garage/data";
            capacity = "100G";
          }
        ];
        metadata_dir = "/srv/garage/meta";
        metadata_snapshots_dir = "/srv/garage/snapshots";

        admin.api_bind_addr = "0.0.0.0:${ports.garage-api.str}";
        # admin.api_bind_addr = "127.0.0.1:${ports.garage-api.str}";
        admin.metrics_require_token = true;
        block_size = "1M";
        compression_level = "none"; # use zfs compression instead
        disable_scrub = false; # maybe enable on zfs?
        metadata_auto_snapshot_interval = "1d";
        replication_factor = 1;
        # rpc_bind_addr = "0.0.0.0:${ports.garage-rpc.str}";
        rpc_bind_addr = "127.0.0.1:${ports.garage-rpc.str}";
        # rpc_public_addr = "[fc00:1::1]:${ports.garage-rpc.str}";
        s3_api = {
          api_bind_addr = "0.0.0.0:${ports.garage-s3.str}";
          # api_bind_addr = "127.0.0.1:${ports.garage-s3.str}";
          s3_region = "garage";
          root_domain = ".${domain-s3}";
          advertise_endpoint = "https://${domain-s3}";
          advertise_path_style = true;
        };
      };
    };
    systemd.services.garage.serviceConfig.DynamicUser = false;
    systemd.services.garage.serviceConfig.User = garage-user;
    systemd.services.garage.serviceConfig.Group = garage-group;

    security.acme.certs.${domain-s3}.extraDomainNames = [ "*.${domain-s3}" ];

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain-s3} = recursiveUpdate nginx.defaultSettings s3ProxySettings;
      "*.${domain-s3}" = recursiveUpdate nginx.defaultSettings s3ProxySettings;
      ${domain-api} = recursiveUpdate nginx.defaultSettings {
        kTLS = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.garage-api.str}";
          extraConfig = internalAcl;
        };
      };
      # ${domain-web} = recursiveUpdate nginx.tinyauthSettings {
      #   kTLS = true;
      #   locations."/" = {
      #     proxyPass = "http://127.0.0.1:${ports.garage-web.str}";
      #     extraConfig = ''
      #       ${internalAcl}
      #       proxy_max_temp_file_size 0;
      #       proxy_busy_buffers_size 1024k;
      #       proxy_buffers 32 1024k;
      #       proxy_buffer_size 1024k;
      #       proxy_read_timeout 86400;

      #       auth_request /tinyauth;
      #       auth_request_set $redirection_url $upstream_http_x_tinyauth_location;
      #       error_page 401 403 =302 $redirection_url;
      #     '';
      #   };
      # };
    };

    networking.firewall.interfaces.br-services.allowedTCPPorts = [
      ports.garage-api.int
      ports.garage-s3.int
    ];

    users.users.${garage-user} = {
      inherit (users.garage) uid;
      group = garage-group;
    };
    users.groups.${garage-group}.gid = users.garage.gid;

    persist.state.directories = [
      metadata_dir
    ]
    ++ lib.optionals (lib.isList data_dir) (map (item: item.path) data_dir)
    ++ lib.optionals (lib.isString data_dir) [ data_dir ];
  };
}
