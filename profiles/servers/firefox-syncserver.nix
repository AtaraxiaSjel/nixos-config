{ pkgs, config, lib, ... }: {
  secrets.firefox-syncserver = {
    # owner = config.services.firefox-syncserver.database.user;
  };

  services.mysql.package = pkgs.mariadb;

  services.firefox-syncserver = {
    enable = true;
    database.createLocally = true;
    secrets = config.secrets.firefox-syncserver.decrypted;
    settings = {
      port = 5000;
      tokenserver.enabled = true;
      # syncserver = {
      #   public_url = "https://fsync.ataraxiadev.com";
      # };
      # endpoints = {
      #   "sync-1.5" = "http://localhost:8000/1.5/1";
      # };
    };
    singleNode = {
      enable = true;
      capacity = 10;
      # enableTLS = false;
      # enableNginx = false;
      # enableTLS = false;
      # enableNginx = true;
      # hostname = "localhost";
      # hostname = "fsync.ataraxiadev.com";
      url = "https://fsync.ataraxiadev.com";
    };
  };
}