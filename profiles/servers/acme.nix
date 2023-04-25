{ config, ... }: {
  security.acme = {
    acceptTerms = true;
    # defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # staging
    defaults.server = "https://acme-v02.api.letsencrypt.org/directory"; # production
    defaults.email = "admin@ataraxiadev.com";
    defaults.renewInterval = "weekly";
  };

  persist.state.directories = [
    "/var/lib/acme"
  ];
}