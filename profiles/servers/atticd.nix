{ config, lib, pkgs, inputs, ... }: {
  imports = [ inputs.attic.nixosModules.atticd ];
  secrets.attic.services = [ "atticd.service" ];

  services.atticd = {
    enable = true;
    credentialsFile = config.secrets.attic.decrypted;
    settings = {
      # listen = "[::]:8080";
      listen = "127.0.0.1:8083";
      allowed-hosts = [ "cache.ataraxiadev.com" ];
      api-endpoint = "https://cache.ataraxiadev.com/";
      require-proof-of-possession = false;
      garbage-collection = {
        interval = "7 days";
        default-retention-period = "2 months";
      };
      # Data chunking
      chunking = {
        nar-size-threshold = 64 * 1024; # 64 KiB
        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB
        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB
        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

  persist.state.directories = [ "/var/lib/private/atticd" ];
}