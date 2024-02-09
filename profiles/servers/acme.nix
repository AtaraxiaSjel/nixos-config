{ config, inputs, ... }: {
  sops.secrets.cf-dns-api = {
    sopsFile = inputs.self.secretsDir + /misc.yaml;
    owner = "acme";
  };
  security.acme = {
    acceptTerms = true;
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # staging
    defaults.server = "https://acme-v02.api.letsencrypt.org/directory"; # production
    defaults.email = "admin@ataraxiadev.com";
    defaults.renewInterval = "weekly";
    certs = {
      "ataraxiadev.com" = {
        extraDomainNames = [ "*.ataraxiadev.com" ];
        dnsResolver = "1.1.1.1:53";
        dnsProvider = "cloudflare";
        credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cf-dns-api.path;
      };
    };
  };
  persist.state.directories = [ "/var/lib/acme" ];
}