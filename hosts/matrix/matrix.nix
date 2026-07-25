{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (config.ataraxia.lists) users;

  acme-cert = config.security.acme.certs."ataraxiadev.com";
  hostname = config.networking.hostName;
  element-web = (
    pkgs.element-web.override {
      conf = {
        default_theme = "dark";
        disable_custom_urls = true;
        disable_guests = true;
        default_server_config = {
          "m.homeserver" = {
            base_url = "https://matrix.ataraxiadev.com";
            server_name = "ataraxiadev.com";
          };
          "org.matrix.msc4143.rtc_foci" = [
            {
              "type" = "livekit";
              "livekit_service_url" = "https://matrix-rtc.ataraxiadev.com";
            }
          ];
          "m.identity_server" = {
            base_url = "";
          };
          element_call = {
            url = "";
          };
          room_directory = {
            servers = [
              "matrix.ataraxiadev.com"
            ];
          };
        };
      };
    }
  );
in
{
  sops.secrets.tuwunel-coturn-secret = {
    sopsFile = secretsDir + /${hostname}/tuwunel.yaml;
    owner = "tuwunel";
    mode = "440";
  };
  sops.secrets.tuwunel-eturnal-secret = {
    sopsFile = secretsDir + /${hostname}/tuwunel.yaml;
    uid = 9000;
    owner = null;
    group = "tuwunel";
    mode = "440";
  };
  sops.secrets.tuwunel-reg-token = {
    sopsFile = secretsDir + /${hostname}/tuwunel.yaml;
    owner = "tuwunel";
  };
  sops.secrets.livekit-config.sopsFile = secretsDir + /${hostname}/livekit.yaml;
  sops.secrets.matrix-jwt-env.sopsFile = secretsDir + /${hostname}/livekit.yaml;

  services.matrix-tuwunel = {
    enable = true;
    # package = inputs.ataraxiasjel-builds.packages.${pkgs.stdenv.hostPlatform.system}.tuwunel;
    package = pkgs.matrix-tuwunel;
    stateDirectory = "tuwunel";
    settings = {
      global = {
        log = "warn";
        server_name = "ataraxiadev.com";
        new_user_displayname_suffix = "";
        unix_socket_path = "/run/tuwunel/tuwunel.sock";
        unix_socket_perms = 660;
        # TODO: db backup
        # dns_cache_entries = 8129;
        allow_registration = true;
        registration_token_file = config.sops.secrets.tuwunel-reg-token.path;
        allow_encryption = true;
        encryption_enabled_by_default_for_room_type = "all";
        allow_federation = false;
        forget_forced_upon_leave = true;
        require_auth_for_profile_requests = true;
        allow_unstable_room_versions = false;
        allow_experimental_room_versions = false;
        trusted_servers = [ ];
        turn_uris = [
          "turns:turn.ataraxiadev.com?transport=udp"
          "turns:turn.ataraxiadev.com?transport=tcp"
          # "turn:turn.ataraxiadev.com?transport=udp"
          # "turn:turn.ataraxiadev.com?transport=tcp"
        ];
        turn_secret_file = config.sops.secrets.tuwunel-eturnal-secret.path;
        # turn_secret_file = config.sops.secrets.tuwunel-coturn-secret.path;
        # "/etc/secrets/turn-shared-secret";
        zstd_compression = true;
        # prune_missing_media = true;
        # delete_rooms_after_leave = true;
        well_known = {
          client = "https://matrix.ataraxiadev.com";
          server = "matrix.ataraxiadev.com:443";
          support_email = "admin@ataraxiadev.com";
          support_mxid = "@ataraxiadev:ataraxiadev.com";
        };
      };
    };
  };
  systemd.services.tuwunel.serviceConfig.DynamicUser = lib.mkForce false;

  virtualisation.quadlet.containers = {
    matrix-rtc-jwt = {
      autoStart = true;
      containerConfig = {
        environments = {
          LIVEKIT_JWT_BIND = ":8081";
          LIVEKIT_URL = "wss://matrix-rtc.ataraxiadev.com";
          LIVEKIT_FULL_ACCESS_HOMESERVERS = "ataraxiadev.com";
        };
        environmentFiles = [ config.sops.secrets.matrix-jwt-env.path ];
        # Tags: 0.4.2, latest
        image = "ghcr.io/element-hq/lk-jwt-service@sha256:e9174b17c7b0048dba3899e50e2c3a6df8ec97657267a7cefa704076b89d3f96";
        networks = [ "host" ];
        # networks = [ networks.br-services.ref ];
        # publishPorts = [ "127.0.0.1:8081:8081/tcp" ];
      };
    };
    matrix-rtc-livekit = {
      autoStart = true;
      containerConfig = {
        exec = "--config /etc/livekit.yaml";
        # Tags: v1.10.1, v1.10, latest
        image = "docker.io/livekit/livekit-server@sha256:698a13999b4b2285866a32903724884b1e10c03259526391d9b3a72d9b73bbb4";
        networks = [ "host" ];
        # networks = [ networks.br-services.ref ];
        # publishPorts = [
        #   "127.0.0.1:7880:7880/tcp"
        #   "7881:7881/tcp"
        #   "50100-50200:50100-50200/udp"
        # ];
        volumes = [
          "${config.sops.secrets.livekit-config.path}:/etc/livekit.yaml:ro"
        ];
      };
    };
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
    '';
    virtualHosts = {
      "matrix.ataraxiadev.com" = {
        serverAliases = [ "matrix.ataraxiadev.com:8448" ];
        extraConfig = ''
          encode zstd gzip
          reverse_proxy unix/${config.services.matrix-tuwunel.settings.global.unix_socket_path}
          tls ${acme-cert.directory}/cert.pem ${acme-cert.directory}/key.pem {
            protocols tls1.2 tls1.3
          }
        '';
      };
      "chat.ataraxiadev.com" = {
        extraConfig = ''
          encode zstd gzip
          root * ${element-web}/
          file_server
          tls ${acme-cert.directory}/cert.pem ${acme-cert.directory}/key.pem {
            protocols tls1.2 tls1.3
          }
        '';
      };
      "matrix-rtc.ataraxiadev.com" = {
        extraConfig = ''
          @jwt_service {
            path /sfu/get* /healthz* /get_token*
          }
          handle @jwt_service {
            reverse_proxy localhost:8081
          }
          handle {
            reverse_proxy localhost:7880 {
              header_up Connection "upgrade"
              header_up Upgrade {http.request.header.Upgrade}
            }
          }
          tls ${acme-cert.directory}/cert.pem ${acme-cert.directory}/key.pem {
            protocols tls1.2 tls1.3
          }
        '';
      };
    };
  };

  users.users.${users.tuwunel.name}.uid = users.tuwunel.uid;
  users.groups.${users.tuwunel.name}.gid = users.tuwunel.gid;
  users.users.caddy.extraGroups = [
    acme-cert.group
    users.tuwunel.name
  ];

  networking.firewall.allowedTCPPorts = [
    443
    7881
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 50100;
      to = 50200;
    }
  ];
}
