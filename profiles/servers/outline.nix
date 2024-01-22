{ config, inputs, ... }: {
  sops.secrets = let
    default = {
      sopsFile = inputs.self.secretsDir + /home-hypervisor/outline.yaml;
      owner = config.services.outline.user;
      restartUnits = [ "outline.service" ];
    };
  in {
    outline-minio-key = default;
    outline-mail = default;
    outline-oidc = default;
    outline-key = default;
    outline-utils = default;
  };
  services.outline = {
    enable = true;
    port = 3010;
    publicUrl = "https://docs.ataraxiadev.com";
    forceHttps = false;

    storage = {
      accessKey = "outline";
      secretKeyFile = config.sops.secrets.outline-minio-key.path;
      region = config.services.minio.region;
      uploadBucketUrl = "https://s3.ataraxiadev.com";
      uploadBucketName = "outline";
      # uploadMaxSize = 0;
    };

    oidcAuthentication = {
      authUrl = "https://auth.ataraxiadev.com/application/o/authorize/";
      tokenUrl = "https://auth.ataraxiadev.com/application/o/token/";
      userinfoUrl = "https://auth.ataraxiadev.com/application/o/userinfo/";
      clientId = "tUs7tv85xlK3W4VOw7AQDMYNXqibpV5H8ofR7zix";
      clientSecretFile = config.sops.secrets.outline-oidc.path;
      scopes = [ "openid" "email" "profile" ];
      usernameClaim = "email";
      displayName = "openid";
    };

    smtp = {
      host = "mail.ataraxiadev.com";
      port = 465;
      secure = true;
      username = "outline@ataraxiadev.com";
      passwordFile = config.sops.secrets.outline-mail.path;
      fromEmail = "Outline <no-reply@ataraxiadev.com>";
      replyEmail = "Outline <outline@ataraxiadev.com>";
    };

    secretKeyFile = config.sops.secrets.outline-key.path;
    utilsSecretFile = config.sops.secrets.outline-utils.path;
  };

  persist.state.directories = [
    "/var/lib/redis-outline"
  ];
}