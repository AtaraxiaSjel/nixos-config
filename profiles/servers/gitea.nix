{ pkgs, config, lib, ... }:
{
  secrets.gitea = {
    owner = "gitea";
  };

  services.gitea = {
    enable = true;
    appName = "AtaraxiaDev Gitea Instance";
    cookieSecure = true;
    database = {
      type = "postgres";
      passwordFile = config.secrets.gitea.decrypted;
    };
    disableRegistration = true;
    domain = "code.ataraxiadev.com";
    httpPort = 6000;
    lfs.enable = true;
    rootUrl = "https://code.ataraxiadev.com";
    settings = {
      server = {
        SSH_DOMAIN = "gitea.ataraxiadev.com";
      };
    };
  };
}
