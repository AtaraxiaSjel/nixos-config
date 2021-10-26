{ pkgs, config, lib, ... }: {
  services.matrix-synapse = {
    enable = true;
    allow_guest_access = true;
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

  services.postgresql.enable = true;

  users.users.matrix-synapse.name = lib.mkForce "matrix-synapse";
}