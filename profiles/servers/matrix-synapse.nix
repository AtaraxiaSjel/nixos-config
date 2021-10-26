{ pkgs, config, lib, ... }: {
  secrets.matrix-secret = {
    owner = "matrix-synapse";
  };
  secrets.matrix-pass = { };

  services.matrix-synapse = {
    enable = true;
    allow_guest_access = true;
    registration_shared_secret = (builtins.readFile config.secrets.matrix-secret.decrypted);
    listeners = [{
      bind_address = "0.0.0.0";
      port = 13748;
      resources = [
        {
          compress = true;
          names = [ "client" ];
        }
        {
          compress = false;
          names = [ "federation" ];
        }
      ];
      type = "http";
      tls = false;
      x_forwarded = true;
    }];
    public_baseurl = "https://ataraxiadev.com";
    server_name = "ataraxiadev.com";
  };

  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD '${builtins.readFile config.secrets.matrix-pass.decrypted}';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';
  };

  users.users.matrix-synapse.name = lib.mkForce "matrix-synapse";
}