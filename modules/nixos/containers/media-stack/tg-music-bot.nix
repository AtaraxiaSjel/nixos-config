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
        # Tags: 3.0.1, 3.0, latest
        image = "ghcr.io/eeegoloauq/music-bot@sha256:3380b187ce81be1d31af7cf3e128aa39be51685c1a08328a0facc3c13b9558ae";
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
