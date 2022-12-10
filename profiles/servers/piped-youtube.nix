{ config, lib, pkgs, ... }:
with config.users.users.${config.mainuser}; with config.users.groups.${group}; {
  secrets."cloudflare-ddns-ataraxiadev" = {
    owner = "${toString uid}";
    # permissions = "400";
  };

  virtualisation.oci-containers.containers.piped = {
    autoStart = true;
    environment = {
      PUID = toString uid;
      PGID = toString gid;
    };
    extraOptions = [
      "--network=host"
      "--security-opt=no-new-privileges:true"
    ];
    ports = [ "127.0.0.1:8080:8080" ];
    image = "1337kavin/piped:latest";
    volumes = [ "${config.secrets.piped-config.decrypted}:/app/config.properties" ];
  };
}