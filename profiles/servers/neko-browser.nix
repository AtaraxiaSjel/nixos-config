{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
in {
  virtualisation.oci-containers.containers.neko-browser = {
    autoStart = true;
    image = "ghcr.io/m1k1o/neko/intel-firefox";
    environment = {
      NEKO_ICELITE = "true";
      NEKO_SCREEN = "1920x1080@30";
      NEKO_PASSWORD = "neko";
      NEKO_PASSWORD_ADMIN = "admin";
      NEKO_TCPMUX = "8091";
      NEKO_UDPMUX = "8092";
      NEKO_BIND = "127.0.0.1:8090";
      NEKO_NAT1TO1 = "91.202.204.123";
    };
    extraOptions = [
      "--cap-add=SYS_ADMIN"
      "--cap-add=SYS_CHROOT"
      "--device=/dev/dri:/dev/dri"
      "--shm-size=1gb"
    ];
    ports = [
      "127.0.0.1:8090:8090"
      "127.0.0.1:8091:8091"
      "127.0.0.1:8092:8092/udp"
    ];
  };
}