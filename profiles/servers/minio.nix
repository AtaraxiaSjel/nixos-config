{ config, lib, pkgs, inputs, ... }: {
  sops.secrets.minio-credentials = {
    owner = "minio";
    mode = "0400";
    sopsFile = inputs.self.secretsDir + /home-hypervisor/minio.yaml;
    restartUnits = [ "minio.service" ];
  };

  services.minio = {
    enable = true;
    browser = true;
    configDir = "/media/nas/minio/config";
    dataDir = [ "/media/nas/minio/data" ];
    listenAddress = "127.0.0.1:9600";
    consoleAddress = "127.0.0.1:9601";
    rootCredentialsFile = config.sops.secrets.minio-credentials.path;
  };

  systemd.services.minio = {
    environment = lib.mkAfter {
      MINIO_SERVER_URL = "https://s3.ataraxiadev.com";
      MINIO_BROWSER_REDIRECT_URL = "https://s3.ataraxiadev.com/ui";
      MINIO_IDENTITY_OPENID_COMMENT="Authentik";
      MINIO_IDENTITY_OPENID_CONFIG_URL = "https://auth.ataraxiadev.com/application/o/minio/.well-known/openid-configuration";
      MINIO_IDENTITY_OPENID_REDIRECT_URI = "https://s3.ataraxiadev.com/ui/oauth_callback";
      MINIO_IDENTITY_OPENID_SCOPES = "openid,profile,email,minio";
    };
  };

  # Sync local minio buckets to remote s3 storage
  sops.secrets.rclone-s3-sync.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  backups.rclone-sync.minio = {
    rcloneConfigFile = config.sops.secrets.rclone-s3-sync.path;
    syncTargets = [
      { source = "minio:ocis"; target = "idrive:ocis-backup"; }
      { source = "minio:outline"; target = "idrive:outline-backup"; }
    ];
  };

  # persist.state.directories = config.services.minio.dataDir ++ [
  #   config.services.minio.configDir
  # ];
}