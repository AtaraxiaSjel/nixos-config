{ config, lib, pkgs, inputs, ... }: {
  imports = [ inputs.attic.nixosModules.atticd ];
  secrets.attic.services = [ "atticd.service" ];

  services.atticd = {
    enable = true;
    credentialsFile = config.secrets.attic.decrypted;
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
    hashedPassword = "$y$j9T$ZC44T3XYOPapB26cyPsA4.$8wlYEbwXFszC9nrg0vafqBZFLMPabXdhnzlT3DhUit6";
  };

  systemd.services.atticd = {
    serviceConfig.DynamicUser = lib.mkForce false;
  };

  services.postgresql = {
    enable = true;
    ensureUsers = [{
      name = "atticd";
      ensurePermissions = {
        "DATABASE atticd" = "ALL PRIVILEGES";
      };
    }];
    ensureDatabases = [ "atticd" ];
  };

  persist.state.directories = [ "/var/lib/atticd" ];
}