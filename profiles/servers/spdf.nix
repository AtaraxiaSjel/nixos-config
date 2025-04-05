{ ... }: let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.spdf = {
    autoStart = true;
    # Tags: latest-fat, 0.45.0-fat
    image = "docker.io/stirlingtools/stirling-pdf@sha256:d3e0d26655d48970d5aa414ce57c5f91c59e3a7ed485729654aa142460151d14";
    environment = {
      PUID = "1000";
      PGID = "100";
      UMASK = "022";
      SECURITY_ENABLE_LOGIN = "false";
      SECURITY_CSRF_DISABLED = "false";
      SYSTEM_DEFAULT_LOCALE = "ru-RU";
      METRICS_ENABLED = "false";
    };
    ports = [ "127.0.0.1:8071:8080/tcp" ];
    volumes = [ "${nas-path}/configs/spdf/configs:/configs" ];
  };

  systemd.tmpfiles.rules = [
    "d ${nas-path}/configs/spdf 0755 1000 100 -"
    "d ${nas-path}/configs/spdf/configs 0755 1000 100 -"
  ];
}