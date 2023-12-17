{ config, pkgs, lib, ... }: {
  secrets = let
    default = {
      owner = config.services.outline.user;
      services = [ "outline.service" ];
    };
  in {
    minio-cred.owner = "minio";
    minio-cred.services = [ "minio.service" ];
    minio-outline = default;
    outline-mail = default;
    outline-oidc = default;
    outline-key = default;
    outline-utils = default;
  };
  services = {
    # TODO: migrate from s3 to local storage
    outline = {
      enable = true;
      port = 3010;
      publicUrl = "https://docs.ataraxiadev.com";
      forceHttps = false;

      storage = {
        accessKey = "outline";
        secretKeyFile = config.secrets.minio-outline.decrypted;
        region = config.services.minio.region;
        uploadBucketUrl = "http://127.0.0.1:9100";
        uploadBucketName = "outline";
        # uploadMaxSize = 0;
      };

      oidcAuthentication = {
        authUrl = "https://auth.ataraxiadev.com/application/o/authorize/";
        tokenUrl = "https://auth.ataraxiadev.com/application/o/token/";
        userinfoUrl = "https://auth.ataraxiadev.com/application/o/userinfo/";
        clientId = "tUs7tv85xlK3W4VOw7AQDMYNXqibpV5H8ofR7zix";
        clientSecretFile = config.secrets.outline-oidc.decrypted;
        scopes = [ "openid" "email" "profile" ];
        usernameClaim = "email";
        displayName = "openid";
      };

      smtp = {
        host = "mail.ataraxiadev.com";
        port = 465;
        secure = true;
        username = "outline@ataraxiadev.com";
        passwordFile = config.secrets.outline-mail.decrypted;
        fromEmail = "Outline <no-reply@ataraxiadev.com>";
        replyEmail = "Outline <outline@ataraxiadev.com>";
      };

      secretKeyFile = config.secrets.outline-key.decrypted;
      utilsSecretFile = config.secrets.outline-utils.decrypted;
    };
    minio = {
      enable = true;
      listenAddress = "127.0.0.1:9100";
      consoleAddress = "192.168.0.10:9101";
      rootCredentialsFile = config.secrets.minio-cred.decrypted;
    };
  };

  networking.firewall.allowedTCPPorts = [ 9101 ];

  persist.state.directories = config.services.minio.dataDir ++ [
    "/var/lib/redis-outline"
    config.services.minio.configDir
  ];
}