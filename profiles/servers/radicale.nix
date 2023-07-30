{ config, pkgs, lib, ... }: {
  secrets.radicale-htpasswd = {
    owner = "radicale";
    services = [ "radicale.service" ];
  };
  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "127.0.0.1:5232" ];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.secrets.radicale-htpasswd.decrypted;
        htpasswd_encryption = "bcrypt";
      };
      storage = {
        filesystem_folder = "/var/lib/radicale/collections";
      };
      web.type = "internal";
    };
  };

  persist.state.directories = [ "/var/lib/radicale" ];
}