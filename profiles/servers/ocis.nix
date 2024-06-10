{ config, pkgs, lib, inputs, modulesPath, ... }: {
  disabledModules = [ "${modulesPath}/services/web-apps/ocis.nix" ];
  imports = with inputs.ataraxiasjel-nur.nixosModules; [ ocis wopiserver ];

  sops.secrets.wopiserver-secret.sopsFile = inputs.self.secretsDir + /home-hypervisor/ocis.yaml;
  sops.secrets.ocis-env-file = {
    owner = "ocis";
    sopsFile = inputs.self.secretsDir + /home-hypervisor/ocis.yaml;
    restartUnits = [ "ocis-server.service" ];
  };

  services.ocis = {
    enable = true;
    package = pkgs.ocis-bin;
    configDir = "/var/lib/ocis/config";
    baseDataPath = "/var/lib/ocis/data";
    settings = {
      proxy.role_assignment = {
        driver = "oidc";
        oidc_role_mapper = {
          role_claim = "groups";
          role_mapping = [
            { role_name = "admin"; claim_value = "ocisAdmin"; }
            { role_name = "spaceadmin"; claim_value = "ocisSpaceAdmin"; }
            { role_name = "user"; claim_value = "ocisUser"; }
            { role_name = "guest"; claim_value = "ocisGuest"; }
          ];
        };
      };
    };
    environmentFile = config.sops.secrets.ocis-env-file.path;
    environment = {
      # Web settings
      OCIS_INSECURE = "false";
      OCIS_LOG_LEVEL = "debug";
      OCIS_URL = "https://file.ataraxiadev.com";
      PROXY_HTTP_ADDR = "127.0.0.1:9200";
      PROXY_TLS = "false";
      PROXY_ENABLE_BASIC_AUTH = "false";
      # Disable embedded idp (we are using authentik) and default app-provider
      OCIS_EXCLUDE_RUN_SERVICES = "idp,app-provider";
      # OIDC Settings
      OCIS_OIDC_ISSUER = "https://auth.ataraxiadev.com/application/o/owncloud-web-client/";
      PROXY_AUTOPROVISION_ACCOUNTS = "true";
      PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "none";
      # PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "jwt";
      PROXY_OIDC_REWRITE_WELLKNOWN = "true";
      PROXY_USER_CS3_CLAIM = "mail";
      PROXY_USER_OIDC_CLAIM = "email";
      # S3 storage
      STORAGE_USERS_DRIVER = "s3ng";
      STORAGE_SYSTEM_DRIVER = "ocis";
      STORAGE_USERS_S3NG_BUCKET = "ocis";
      STORAGE_USERS_S3NG_ENDPOINT = "https://s3.ataraxiadev.com";
      STORAGE_USERS_S3NG_REGION = "us-east-1";
      # OnlyOffice app provider
      APP_PROVIDER_SERVICE_NAME = "app-provider-onlyoffice";
      APP_PROVIDER_EXTERNAL_ADDR = "com.owncloud.api.app-provider-onlyoffice";
      APP_PROVIDER_DRIVER = "wopi";
      APP_PROVIDER_WOPI_APP_NAME = "OnlyOffice";
      APP_PROVIDER_WOPI_APP_ICON_URI = "https://office.ataraxiadev.com/web-apps/apps/documenteditor/main/resources/img/favicon.ico";
      APP_PROVIDER_WOPI_APP_URL = "https://office.ataraxiadev.com";
      APP_PROVIDER_WOPI_INSECURE = "false";
      APP_PROVIDER_WOPI_WOPI_SERVER_EXTERNAL_URL = "https://wopi.ataraxiadev.com";
      APP_PROVIDER_WOPI_FOLDER_URL_BASE_URL = "https://file.ataraxiadev.com";
    };
  };

  services.wopiserver = {
    enable = true;
    settings = {
      general = {
        storagetype = "cs3";
        port = "8880";
        loglevel = "Info";
        loghandler = "stream";
        logdest = "stdout";
        wopiurl = "https://wopi.ataraxiadev.com";
        downloadurl = "https://wopi.ataraxiadev.com/wopi/iop/download";
        internalserver = "waitress";
        nonofficetypes = ".md .zmd .txt .epd";
        tokenvalidity = "86400";
        wopilockexpiration = "3600";
        wopilockstrictcheck = "True";
        enablerename = "False";
        detectexternallocks = "False";
      };
      security = {
        wopisecretfile = "/run/credentials/wopiserver.service/wopisecret";
        usehttps = "no";
      };
      bridge = {
        sslverify = "True";
      };
      io = {
        chunksize = "4194304";
        recoverypath = "/var/lib/wopi/recovery";
      };
      cs3 = {
        revagateway = "127.0.0.1:9142";
        authtokenvalidity = "3600";
        sslverify = "True";
      };
    };
  };

  # persist.state.directories = [ "/var/lib/ocis" ];

  systemd.services.ocis-server.after =
    lib.mkIf config.services.authentik.enable [
      "authentik-server.service"
      "authentik-worker.service"
      "nginx.service"
    ];

  systemd.services.wopiserver.serviceConfig.LoadCredential =
    "wopisecret:${config.sops.secrets.wopiserver-secret.path}";
}
