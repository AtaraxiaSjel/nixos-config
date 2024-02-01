{ config, lib, inputs, ... }:
let
  minio-secret = {
    owner = "minio";
    mode = "0400";
    sopsFile = inputs.self.secretsDir + /home-hypervisor/minio.yaml;
    restartUnits = [ "minio.service" ];
  };
  kes-secret = {
    owner = "kes";
    mode = "0400";
    sopsFile = inputs.self.secretsDir + /home-hypervisor/minio.yaml;
    restartUnits = [ "kes.service" ];
  };
in {
  imports = [ inputs.ataraxiasjel-nur.nixosModules.kes ];

  sops.secrets.minio-credentials = minio-secret;
  sops.secrets.kes-vault-env = kes-secret;
  sops.secrets.kes-key = kes-secret;
  sops.secrets.kes-cert = kes-secret // {
    group = "minio";
    mode = "0440";
    restartUnits = [ "kes.service" "minio.service" ];
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
      MINIO_IDENTITY_OPENID_COMMENT = "Authentik";
      MINIO_IDENTITY_OPENID_CONFIG_URL =
        "https://auth.ataraxiadev.com/application/o/minio/.well-known/openid-configuration";
      MINIO_IDENTITY_OPENID_REDIRECT_URI =
        "https://s3.ataraxiadev.com/ui/oauth_callback";
      MINIO_IDENTITY_OPENID_SCOPES = "openid,profile,email,minio";
      # KMS
      MINIO_KMS_KES_ENDPOINT = "https://${config.services.kes.settings.address}";
      MINIO_KMS_KES_CAPATH = config.sops.secrets.kes-cert.path;
      MINIO_KMS_KES_KEY_NAME = "minio-default-key";
      MINIO_KMS_KES_ENCLAVE = "minio-hypervisor";
    };
  };
  systemd.services.minio.after =
    lib.mkIf config.services.authentik.enable [
      "authentik-server.service"
      "authentik-worker.service"
      "nginx.service"
      "kes.service"
    ];

  services.kes = {
    enable = true;
    environmentFile = config.sops.secrets.kes-vault-env.path;
    settings = {
      address = "127.0.0.1:7373";
      admin.identity = "disabled";
      tls = {
        key = config.sops.secrets.kes-key.path;
        cert = config.sops.secrets.kes-cert.path;
      };
      policy.minio = {
        allow = [
          "/v1/key/create/minio-*"
          "/v1/key/generate/minio-*"
          "/v1/key/decrypt/minio-*"
          "/v1/key/bulk/decrypt"
          "/v1/key/list/*"
          "/v1/status"
          "/v1/metrics"
          "/v1/log/audit"
          "/v1/log/errot"
        ];
        identities = [
          "d76b126754bd382de969e18ab71c3ba3fe1fdf9bb89927b3f16e08ebae07d242"
        ];
      };
      keystore.vault = {
        endpoint = "http://${config.services.vault.address}";
        engine = "kv/";
        version = "v1";
        approle = {
          id = ''''${KES_APPROLE_ID}'';
          secret = ''''${KES_APPROLE_SECRET}'';
          retry = "15s";
        };
        status.ping = "10s";
      };
    };
  };
  systemd.services.kes.after = [ "vault.service" "vault-unseal.service" ];

  # Sync local minio buckets to remote s3 storage
  sops.secrets.rclone-s3-sync.sopsFile = inputs.self.secretsDir + /rustic.yaml;
  backups.rclone-sync.minio = {
    rcloneConfigFile = config.sops.secrets.rclone-s3-sync.path;
    syncTargets =
      let buckets = [
        "authentik-media" "ocis" "outline"
        "obsidian-ataraxia" "obsidian-doste" "obsidian-kpoxa"
      ]; in map (bucket: {
        source = "minio:${bucket}";
        target = "idrive:minio-${bucket}";
      }) buckets;
  };
}
