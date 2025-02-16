{ ... }: let
  nas-path = "/media/nas/media-stack";
in {
  virtualisation.oci-containers.containers.spdf = {
    autoStart = true;
    # Tags: latest-fat, 0.41.0-fat
    image = "docker.io/stirlingtools/stirling-pdf@sha256:e791d48580806f6dade7c9774b7137d40ebbf1f35b86c592877d32eae2cbf0ad";
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