{ lib, ... }: {
  services.scrutiny = {
    enable = true;
    influxdb.enable = true;
    openFirewall = true;
    collector = {
      enable = false;
    };
    settings = {
      web.listen.host = "0.0.0.0";
      # web.listen.host = "127.0.0.1";
      web.listen.port = 8090;
    };
  };
  # systemd.services.scrutiny = {
  #   environment.SCRUTINY_WEB_DATABASE_LOCATION = lib.mkForce "/srv/scrutiny.db";
  # };
  persist.state.directories = [
    "/var/db/influxdb"
    "/var/lib/scrutiny"
  ];
}