{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.ataraxia.lists) ports users;
  inherit (config.virtualisation.quadlet) pods;

  cfg = config.ataraxia.containers.media-stack;
  users-gid = toString config.users.groups."users".gid;
  users-name = config.users.groups."users".name;

  nas-path = "/media/nas/media-stack";
  share-path = "/media/nas/media-stack/media/soulseek";
in
{
  options.ataraxia.containers.media-stack = {
    tg-music-bot = mkEnableOption "Enable tg-music-bot container";
  };

  config = mkIf cfg.tg-music-bot {
    sops.secrets.tg-music-bot = {
      sopsFile = secretsDir + /${cfg.sopsDir}/tg-music-bot.yaml;
      owner = users.slskd.name;
      restartUnits = [ "tg-music-bot.service" ];
    };
    virtualisation.quadlet.containers.tg-music-bot = {
      autoStart = true;
      containerConfig = {
        # Tags: latest, 3.0.2, 3.0
        image = "ghcr.io/eeegoloauq/music-bot@sha256:2893f38b1cdec9581bd19e602f9979e151c8cedec9af59ef8073b04e3a66c677";
        pod = pods.media-stack.ref;
        environments = {
          SLSKD_HOST = "http://host.containers.internal:${ports.slskd.str}";
          SLSKD_DOWNLOAD_DIR = "/music/.slskd-downloads";
          NAVIDROME_URL = "http://navidrome:4533";
          NAVIDROME_PUBLIC_URL = "https://music.ataraxiadev.com";
          HTTP_PROXY = "http://10.10.10.6:8888";
          HTTPS_PROXY = "http://10.10.10.6:8888";
          NO_PROXY = "localhost,127.0.0.1,host.containers.internal,navidrome,slskd";
        };
        environmentFiles = [ config.sops.secrets.tg-music-bot.path ];
        user = "${users.slskd.uidStr}:${users-gid}";
        volumes = [
          "${nas-path}/configs/tg-music-bot:/data"
          "${share-path}/share:/music"
        ];
      };
    };
    systemd.tmpfiles.rules = [
      "d ${nas-path}/configs/tg-music-bot 0750 ${users.slskd.name} ${users-name} -"
    ];
  };
}
