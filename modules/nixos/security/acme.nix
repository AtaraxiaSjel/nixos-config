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
      defaults = {
        # server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # staging
        server = "https://acme-v02.api.letsencrypt.org/directory"; # production
        email = "admin@ataraxiadev.com";
        renewInterval = "weekly";
        group = mkIf nginxEnabled nginxGroup;
        # DNS challenge
        dnsResolver = "1.1.1.1:53";
        dnsProvider = "cloudflare";
        credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cf-dns-api.path;
        extraLegoFlags = [
          "--dns.propagation-wait"
          "60s"
        ];
      };
      certs = {
        "ataraxiadev.com".extraDomainNames = [ "*.ataraxiadev.com" ];
      };
    };
    persist.state.directories = [ "/var/lib/acme" ];
  };
}
