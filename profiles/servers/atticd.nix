{ config, lib, inputs, ... }: {
  imports = [ inputs.attic.nixosModules.atticd ];
  sops.secrets.atticd.sopsFile = inputs.self.secretsDir + /home-hypervisor/atticd.yaml;
  sops.secrets.atticd.restartUnits = [ "atticd.service" ];

  services.atticd = {
    enable = true;
    credentialsFile = config.sops.secrets.atticd.path;
    user = "atticd";
    group = "atticd";
    settings = {
      listen = "127.0.0.1:8083";
      database.url = "postgresql:///atticd?host=/run/postgresql";
      allowed-hosts = [ "cache.ataraxiadev.com" ];
      api-endpoint = "https://cache.ataraxiadev.com/";
      require-proof-of-possession = false;
      garbage-collection = {
        interval = "3 days";
        default-retention-period = "1 month";
      };
      chunking = {
        nar-size-threshold = 64 * 1024; # 64 KiB
        min-size = 16 * 1024; # 16 KiB
        avg-size = 64 * 1024; # 64 KiB
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

  users.groups.atticd = {};
  users.users.atticd = {
    isSystemUser = true;
    group = "atticd";
  };

  systemd.services.atticd = {
    serviceConfig.DynamicUser = lib.mkForce false;
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [{
      name = "atticd";
      ensureDBOwnership = true;
    }];
    ensureDatabases = [ "atticd" ];
  };

  backups.postgresql.atticd = {};

  persist.state.directories = [ "/var/lib/atticd" ];
}