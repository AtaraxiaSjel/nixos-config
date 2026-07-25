{
  config,
  secretsDir,
  ...
}:
{
  sops.secrets.cf-dns-api = {
    sopsFile = secretsDir + /misc.yaml;
    owner = "acme";
  };
  sops.secrets.eab-zerossl-env = {
    sopsFile = secretsDir + /misc.yaml;
    owner = "acme";
  };
  security.acme = {
    acceptTerms = true;
    defaults.server = "https://acme.zerossl.com/v2/DV90";
    defaults.email = "ataraxiadev@ataraxiadev.com";
    defaults.renewInterval = "2month";
    certs = {
      "ataraxiadev.com" = {
        extraDomainNames = [ "*.ataraxiadev.com" ];
        dnsResolver = "1.1.1.1:53";
        dnsProvider = "cloudflare";
        credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cf-dns-api.path;
        extraLegoFlags = [
          "--dns.propagation-wait"
          "60s"
          "--eab"
        ];
        environmentFile = config.sops.secrets.eab-zerossl-env.path;
        reloadServices = [
          "caddy.service"
          "eturnal.service"
        ];
        postRun = ''
          rm /run/eturnal/fullchain.pem /run/eturnal/key.pem
          cp fullchain.pem key.pem /run/eturnal
          chown 9000:9000 /run/eturnal/fullchain.pem /run/eturnal/key.pem
          chmod 440 /run/eturnal/fullchain.pem /run/eturnal/key.pem
        '';
      };
    };
  };
  persist.state.directories = [ "/var/lib/acme" ];
  systemd.tmpfiles.rules = [ "d /run/eturnal 0750 9000 9000 -" ];
}
