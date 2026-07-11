{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool str;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.services.slskd;
  nginx = config.ataraxia.services.nginx;
  domain = "slskd.ataraxiadev.com";

  share-path = "/media/nas/media-stack/media/soulseek";
in
{
  options.ataraxia.services.slskd = {
    enable = mkEnableOption "Enable slskd service";
    sopsDir = mkOption {
      type = str;
      default = config.networking.hostName;
      description = ''
        Name for sops secrets directory. Defaults to hostname.
      '';
    };
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.slskd-env = {
      sopsFile = secretsDir + /${cfg.sopsDir}/slskd.yaml;
      owner = config.services.slskd.user;
    };
    services.slskd = {
      enable = true;
      domain = null;
      environmentFile = config.sops.secrets.slskd-env.path;
      openFirewall = true;
      settings = {
        web.port = ports.slskd.int;
        soulseek.listen_port = ports.slskd-soulseek.int;
        directories.downloads = "${share-path}/downloads";
        directories.incomplete = "${share-path}/incomplete";
        shares.directories = [ "${share-path}/share" ];
        transfers.upload.speed_limit = "4096";
      };
    };

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.tinyauthSettings {
        kTLS = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${ports.slskd.str}";
          proxyWebsockets = true;
          extraConfig = ''
            allow 127.0.0.1/32;
            allow 100.64.0.0/16;
            allow 10.10.10.0/24;
            allow fd7a:115c:a1e0::/64;
            deny all;
            proxy_busy_buffers_size 1024k;
            proxy_buffers 32 1024k;
            proxy_buffer_size 1024k;
            proxy_read_timeout 86400;

            auth_request /tinyauth;
            error_page 401 = @tinyauth_login;
          '';
        };
      };
    };

    persist.state.directories = [ "/var/lib/slskd" ];
  };
}
