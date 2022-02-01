{ config, lib, pkgs, ... }:
with config.users.users.alukard; with config.users.groups.${group}; {
  secrets."cloudflare-ddns-ataraxiadev" = {
    owner = "${toString uid}";
    # permissions = "400";
  };

  virtualisation.oci-containers.containers.cloudflare-ddns = {
    autoStart = true;
    environment = {
      PUID = toString uid;
      PGID = toString gid;
    };
    extraOptions = [
      "--network=host"
      "--security-opt=no-new-privileges:true"
    ];
    image = "timothyjmiller/cloudflare-ddns:latest";
    volumes = [ "${config.secrets.cloudflare-ddns-ataraxiadev.decrypted}:/config.json" ];
  };
}