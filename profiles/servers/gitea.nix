{ pkgs, config, lib, ... }:
{
  secrets.gitea = {
    owner = "gitea";
  };

  services.gitea = {
    enable = true;
    appName = "AtaraxiaDev's Gitea Instance";
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
    stateDir = "/gitea/data";
    settings = {
      ui = {
        DEFAULT_THEME = "arc-green";
      };
    };
    # ssh = {
    #   enable = true;
    #   clonePort = 2222;
    # };
    # settings = {
    #   server = {
    #     START_SSH_SERVER = true;
    #     SSH_LISTEN_HOST = "0.0.0.0";
    #     SSH_LISTEN_PORT = 2222;
    #   };
    # };
  };
}