{
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (config.ataraxia.lists) users;

  cert-dir = "/run/caddy";
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
  services.matrix-tuwunel = {
    enable = true;
    package = inputs.nix-builds.packages.${pkgs.hostPlatform.system}.default;
    stateDirectory = "tuwunel";
    settings = {
      global = {
        log = "warn";
        server_name = "ataraxiadev.com";
        new_user_displayname_suffix = "";
        unix_socket_path = "/run/tuwunel/tuwunel.sock";
        unix_socket_perms = 660;
        # TODO: db backup
        dns_cache_entries = 8129;
        allow_registration = false;
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
          "turn:turn.ataraxiadev.com?transport=udp"
          "turn:turn.ataraxiadev.com?transport=tcp"
        ];
        # not declarative enough, but its ok. its much simplier to create and mount
        # volume in incus, instead of managing ssh host key in container for sops-nix
        turn_secret_file = "/etc/secrets/turn-shared-secret";
        zstd_compression = true;
        # prune_missing_media = true;
        # delete_rooms_after_leave = true;
        well_known = {
          client = "https://matrix.ataraxiadev.com";
          server = "matrix.ataraxiadev.com:443";
          support_email = "admin@ataraxiadev.com";
          support_mxid = "@ataraxiadev:ataraxiadev.com";
        };
        ldap = {
          enable = true;
          uri = "ldap://ldap.ataraxiadev.com:3890";
          base_dn = "dc=ataraxiadev,dc=com";
          bind_dn = "uid=ldap-search,ou=people,dc=ataraxiadev,dc=com";
          bind_password_file = "/etc/secrets/ldap-bind-pass"; # not declarative, again
          filter = "(&(objectClass=person)(memberOf=cn=Matrix Users,ou=groups,dc=ataraxiadev,dc=com))";
          uid_attribute = "uid";
          name_attribute = "display_name";
          admin_filter = "(&(objectClass=person)(memberOf=cn=Matrix Admins,ou=groups,dc=ataraxiadev,dc=com))";
        };
      };
    };
  };

  users.users.${users.tuwunel.name}.uid = users.tuwunel.uid;
  users.groups.${users.tuwunel.name}.gid = users.tuwunel.gid;
  users.users.caddy.extraGroups = [ users.tuwunel.name ];

  services.caddy = {
    enable = true;
    globalConfig = ''
      admin off
      auto_https off
    '';
    virtualHosts = {
      "matrix.ataraxiadev.com" = {
        # serverAliases = [ "matrix.ataraxiadev.com:8448" ];
        extraConfig = ''
          encode zstd gzip
          reverse_proxy unix/${config.services.matrix-tuwunel.settings.global.unix_socket_path} {
            header_up X-Forwarded-Port {http.request.port}
            header_up X-Forwarded-TlsProto {tls_protocol}
            header_up X-Forwarded-TlsCipher {tls_cipher}
            header_up X-Forwarded-HttpsProto {proto}
          }
          tls ${cert-dir}/ataraxiadev.com.cer ${cert-dir}/ataraxiadev.com.key {
            protocols tls1.2 tls1.3
          }
        '';
      };
      "chat.ataraxiadev.com" = {
        extraConfig = ''
          encode zstd gzip
          root * ${element-web}/
          file_server

          tls ${cert-dir}/ataraxiadev.com.cer ${cert-dir}/ataraxiadev.com.key {
            protocols tls1.2 tls1.3
          }
        '';
      };
    };
  };

  # TODO: change to reload. For now reload throws this error:
  ### Error: sending configuration to instance: performing request:
  ### Post "http://localhost:2019/load": dial tcp 127.0.0.1:2019:
  ### connect: connection refused
  systemd.services.caddy-cert-watcher = {
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.coreutils
      config.systemd.package
    ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "caddy-cert-watcher" ''
        mkdir ${cert-dir} || true
        current_certificate_sha=$(test -f ${cert-dir}/ataraxiadev.com.cer && sha256sum ${cert-dir}/ataraxiadev.com.cer | cut -d" " -f1 || echo "")
        new_certificate_sha=$(sha256sum /etc/acme/ataraxiadev.com_ecc/fullchain.cer | cut -d" " -f1)
        if [[ "$current_certificate_sha" != "$new_certificate_sha" ]]; then
          echo "Certificates are not the same. Copying new certs and reload caddy.service..."
          install -o caddy -g caddy -m 600 \
              /etc/acme/ataraxiadev.com_ecc/fullchain.cer ${cert-dir}/ataraxiadev.com.cer
          install -o caddy -g caddy -m 600 \
              /etc/acme/ataraxiadev.com_ecc/ataraxiadev.com.key ${cert-dir}/ataraxiadev.com.key
          systemctl restart caddy.service && echo "Done."
        else
          echo "Certificates are the same. Do nothing."
        fi
      '';
      Restart = "on-failure";
      RestartPreventExitStatus = 1;
      RestartSec = "5s";
      NoNewPrivileges = true;
    };
    startAt = "1h";
    startLimitBurst = 10;
  };

  networking.firewall.allowedTCPPorts = [
    443
    8448
  ];
}
