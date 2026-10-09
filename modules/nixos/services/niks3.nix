{
  config,
  lib,
  inputs,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool str;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.services.niks3;
  nginx = config.ataraxia.services.nginx;

  domain = "nix-cache.ataraxiadev.com";
  niks3-user = "niks3";

  sopsDefaults = {
    sopsFile = secretsDir + /${cfg.sopsDir}/niks3.yaml;
    owner = niks3-user;
    restartUnits = [ "niks3.service" ];
  };
in
{
  imports = [
    inputs.niks3.nixosModules.niks3
    # inputs.niks3.nixosModules.niks3-auto-upload
  ];

  options.ataraxia.services.niks3 = {
    enable = mkEnableOption "Enable niks3 service";
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
    sops.secrets = {
      niks3-api-token = sopsDefaults;
      niks3-signing-key = sopsDefaults;
      niks3-s3-access-key = sopsDefaults;
      niks3-s3-secret-key = sopsDefaults;
    };

    services.niks3 = {
      enable = true;
      httpAddr = "127.0.0.1:${ports.niks3.str}";
      apiTokenFile = config.sops.secrets.niks3-api-token.path;
      signKeyFiles = [ config.sops.secrets.niks3-signing-key.path ];
      cacheUrl = "https://${domain}";
      gc = {
        enable = true;
        olderThan = "1080h"; # 45 days
        failedUploadsOlderThan = "12h";
      };
      s3 = {
        bucket = "niks3-nix-cache";
        bucketLookup = "path";
        region = "garage";
        publicUrl = "https://s3.ataraxiadev.com";
        endpoint = "127.0.0.1:${ports.garage-s3.str}";
        useSSL = false;
        accessKeyFile = config.sops.secrets.niks3-s3-access-key.path;
        secretKeyFile = config.sops.secrets.niks3-s3-secret-key.path;
      };
      readProxy.enable = true;
      readProxy.redirectTTL = "30m";
      priority = 10;
      nginx.enable = false;
      # oidc = { };
      # Maximum uncompressed NAR size accepted for upload (optional).
      # maxNarSize = "2G";
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.niks3.str}";
          extraConfig = ''
            client_max_body_size 0;
            proxy_connect_timeout 300s;
            proxy_send_timeout 300s;
            proxy_read_timeout 300s;
          '';
        };
      };
    };

    persist.state.directories = [ "/var/lib/niks3" ];
  };
}
