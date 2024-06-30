{ config, ... }:
let
  cert-fqdn = "tg.ataraxiadev.com";
in {
  security.acme.certs = {
    ${cert-fqdn} = {
      dnsResolver = "1.1.1.1:53";
      dnsProvider = "cloudflare";
      credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cf-dns-api.path;
    };
  };

  services.nginx.virtualHosts = {
    ${cert-fqdn} = {
      useACMEHost = cert-fqdn;
      enableACME = false;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://192.168.0.100:3456";
      };
    };
  };
}