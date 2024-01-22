{ config, inputs, ... }: {
  sops.secrets.radicale-htpasswd = {
    sopsFile = inputs.self.secretsDir + /home-hypervisor/radicale.yaml;
    owner = "radicale";
    restartUnits = [ "radicale.service" ];
  };
  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "127.0.0.1:5232" ];
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.secrets.radicale-htpasswd.path;
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