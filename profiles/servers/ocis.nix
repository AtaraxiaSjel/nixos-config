{ config, lib, pkgs, inputs, ... }: {
  sops.secrets.ocis-env-file = {
    owner = "ocis";
    mode = "0400";
    sopsFile = inputs.self.secretsDir + /home-hypervisor/ocis.yaml;
    restartUnits = [ "ocis-server.service" ];
  };
  services.ocis = {
    enable = true;
    configDir = "/var/lib/ocis";
    baseDataPath = "/media/nas/ocis";
    environmentFile = config.sops.secrets.ocis-env-file.path;
    environment = {
      # Web settings
      OCIS_INSECURE = "false";
      OCIS_LOG_LEVEL = "debug";
      OCIS_URL = "https://file.ataraxiadev.com";
      PROXY_HTTP_ADDR = "127.0.0.1:9200";
      PROXY_TLS = "false";
      # Disable embedded idp (we are using authentik)
      OCIS_EXCLUDE_RUN_SERVICES = "idp";
      # OIDC Settings
      OCIS_OIDC_ISSUER = "https://auth.ataraxiadev.com/application/o/owncloud-web-client/";
      PROXY_AUTOPROVISION_ACCOUNTS = "true";
      PROXY_OIDC_ACCESS_TOKEN_VERIFY_METHOD = "jwt";
      PROXY_OIDC_REWRITE_WELLKNOWN = "true";
      PROXY_ROLE_ASSIGNMENT_DRIVER = "oidc";
      PROXY_ROLE_ASSIGNMENT_OIDC_CLAIM = "groups";
      PROXY_USER_CS3_CLAIM = "mail";
      PROXY_USER_OIDC_CLAIM = "email";
      # S3 storage
      STORAGE_USERS_DRIVER = "s3ng";
      STORAGE_SYSTEM_DRIVER = "ocis";
      STORAGE_USERS_S3NG_BUCKET = "ocis";
      STORAGE_USERS_S3NG_ENDPOINT = "https://s3.ataraxiadev.com";
      STORAGE_USERS_S3NG_REGION = "us-east-1";
    };
  };
}