{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.security.acme;
  nginxEnabled = config.ataraxia.services.nginx.enable;
  nginxGroup = config.services.nginx.group;
in
{
  options.ataraxia.security.acme = {
    enable = mkEnableOption "Default acme settings";
  };

  config = mkIf cfg.enable {
    sops.secrets.cf-dns-api = {
      sopsFile = secretsDir + /misc.yaml;
      owner = "acme";
    };
    security.acme = {
      acceptTerms = true;
      # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # staging
      defaults.server = "https://acme-v02.api.letsencrypt.org/directory"; # production
      defaults.email = "admin@ataraxiadev.com";
      defaults.renewInterval = "weekly";
      defaults.group = mkIf nginxEnabled nginxGroup;
      certs = {
        "ataraxiadev.com" = {
          extraDomainNames = [ "*.ataraxiadev.com" ];
          dnsResolver = "1.1.1.1:53";
          dnsProvider = "cloudflare";
          credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cf-dns-api.path;
          extraLegoFlags = [
            "--dns.propagation-wait"
            "60s"
          ];
        };
      };
    };
    persist.state.directories = [ "/var/lib/acme" ];
  };
}
