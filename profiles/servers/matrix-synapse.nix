{ pkgs, config, lib, options, ... }: {
  services.postgresql.enable = true;
  services.postgresqlBackup = {
    enable = true;
    location = config.users.users.alukard.home + "/matrix-backup";
    startAt = "*-*-* 07:00:00";
  };

  services.matrix-synapse = with config.services.coturn; {
    enable = true;
    allow_guest_access = true;
    app_service_config_files = [ config.secrets-envsubst.mautrix-telegram-registration.substituted ];
    extraConfigFiles = [ config.secrets-envsubst.matrix-shared-secret.substituted ];
    logConfig = options.services.matrix-synapse.logConfig.default + ''
      loggers:
          shared_secret_authenticator:
              level: INFO
    '';
    listeners = [{
      bind_address = "0.0.0.0";
      port = 13748;
      resources = [
        {
          compress = true;
          names = [ "client" ];
        }
        {
          compress = false;
          names = [ "federation" ];
        }
      ];
      type = "http";
      tls = false;
      x_forwarded = true;
    }];
    plugins = with pkgs.matrix-synapse-plugins; [ matrix-synapse-shared-secret-auth ];
    public_baseurl = "https://ataraxiadev.com";
    server_name = "ataraxiadev.com";
    turn_uris = [ "turns:${realm}?transport=udp" "turns:${realm}?transport=tcp" ];
    turn_user_lifetime = "24h";
  };

  secrets-envsubst.matrix-shared-secret = {
    directory = "mautrix-telegram";
    owner = "matrix-synapse";
    secrets = [ "shared_secret" "reg_shared_secret" "turn_shared_secret" ];
    template = ''
      registration_shared_secret: $reg_shared_secret
      turn_allow_guests: False
      turn_shared_secret: $turn_shared_secret
      password_providers:
        - module: "shared_secret_authenticator.SharedSecretAuthenticator"
          config:
            sharedSecret: "$shared_secret"
    '';
  };

  services.mautrix-telegram = {
    enable = true;
    environmentFile = toString config.secrets-envsubst.mautrix-telegram;
    settings = {
      appservice = {
        address = "http://localhost:29317";
        bot_avatar = "mxc://maunium.net/tJCRmUyJDsgRNgqhOgoiHWbX";
        database = "postgresql://mautrix-telegram:$MATRIX_PASS@localhost/mautrix-telegram";
        id = "telegram";
        max_body_size = 1;
        port = 29317;
        public = {
          enabled = true;
          prefix = "/mautrix-telegram";
          external = "https://matrix.ataraxiadev.com/mautrix-telegram";
        };
        provisioning.enabled = false;
      };
      bridge = {
        alias_template = "tg_{groupname}";
        allow_matrix_login = false;
        animated_sticker = {
          target = "gif";
          args = {
            width = 128;
            height = 128;
            fps = 30;
            background = "15191E";
          };
        };
        bot_messages_as_notices = true;
        catch_up = true;
        command_prefix = "!tg";
        encryption = {
          allow = true;
          default = false;
        };
        filter = {
          mode = "whitelist";
          list = [ ];
        };
        image_as_file_size = 10;
        login_shared_secret_map."ataraxiadev.com" = "$SHARED_SECRET_AUTH";
        max_document_size = 100;
        max_initial_member_sync = -1;
        max_telegram_delete = 10;
        permissions = {
          "*" = "relaybot";
          "@ataraxiadev:ataraxiadev.com" = "admin";
          "@kpoxa:ataraxiadev.com" = "full";
        };
        plaintext_highlights = true;
        startup_sync = false;
        sync_direct_chat_list = false;
        sync_direct_chats = false;
        username_template = "tg_{userid}";
      };
      homeserver = {
        address = "https://matrix.ataraxiadev.com";
        asmux = false;
        domain = "ataraxiadev.com";
        verify_ssl = true;
      };
      telegram = { bot_token = "disabled"; };
    };
  };

  secrets-envsubst.mautrix-telegram = {
    secrets = [ "as_token" "hs_token" "api_id" "api_hash" "matrix_pass" "shared_secret" ];
    template = ''
      MAUTRIX_TELEGRAM_APPSERVICE_AS_TOKEN=$as_token
      MAUTRIX_TELEGRAM_APPSERVICE_HS_TOKEN=$hs_token
      MAUTRIX_TELEGRAM_TELEGRAM_API_ID=$api_id
      MAUTRIX_TELEGRAM_TELEGRAM_API_HASH=$api_hash
      MATRIX_PASS=$matrix_pass
      SHARED_SECRET_AUTH=$shared_secret
    '';
  };

  secrets-envsubst.mautrix-telegram-registration = {
    directory = "mautrix-telegram";
    secrets = [ "as_token" "hs_token" "sender_localpart" ];
    owner = "matrix-synapse";
    template = builtins.toJSON {
      as_token = "$as_token";
      hs_token = "$hs_token";
      id = "telegram";
      namespaces = {
        aliases = [{
          exclusive = true;
          regex = "#tg_.+:ataraxiadev.com";
        }];
        users = [{
          exclusive = true;
          regex = "@tg_.+:ataraxiadev.com";
        } {
          exclusive = true;
          regex = "@telegrambot:ataraxiadev.com";
        }];
      };
      rate_limited = false;
      sender_localpart = "$sender_localpart";
      url = "http://localhost:29317";
    };
  };

  systemd.services.mautrix-telegram = {
    path = with pkgs; [ lottieconverter ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "mautrix-telegram";
    };
  };

  users.users.mautrix-telegram = {
    group = "mautrix-telegram";
    isSystemUser = true;
  };

  users.groups.mautrix-telegram = {};

  users.users.matrix-synapse.name = lib.mkForce "matrix-synapse";
}