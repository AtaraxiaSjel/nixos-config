{
  config,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib) recursiveUpdate;
  nginx = config.ataraxia.services.nginx;
in
{
  ataraxia.services.nginx.enable = true;
  ataraxia.services.nginx.defaultSettings = {
    useACMEHost = "ataraxiadev.com";
    enableACME = false;
    forceSSL = true;
  };
  ataraxia.services.nginx.tinyauthSettings = recursiveUpdate nginx.defaultSettings {
    # TODO: Fix "/" location recursiveUpdate. Maybe rewrite recursiveUpdateUntil to concat types.lines?
    locations."/".extraConfig = ''
      auth_request /tinyauth;
      error_page 401 = @tinyauth_login;
    '';
    locations."/tinyauth" = {
      proxyPass = "http://127.0.0.1:3100/api/auth/nginx";
      extraConfig = ''
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Uri $request_uri;
      '';
    };
    locations."@tinyauth_login" = {
      extraConfig = ''
        return 302 http://tinyauth.ataraxiadev.com/login?redirect_uri=$scheme://$http_host$request_uri;
      '';
    };
  };

  sops.secrets = {
    incus-crt = {
      sopsFile = secretsDir + /${config.networking.hostName}/incus.yaml;
      reloadUnits = [ "nginx.service" ];
      owner = "nginx";
    };
    incus-key = {
      sopsFile = secretsDir + /${config.networking.hostName}/incus.yaml;
      reloadUnits = [ "nginx.service" ];
      owner = "nginx";
    };
  };

  services.nginx.virtualHosts = {
    "incus.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
      locations."/" = {
        proxyPass = "https://10.10.10.5:8443";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_certificate ${config.sops.secrets.incus-crt.path};
          proxy_ssl_certificate_key ${config.sops.secrets.incus-key.path};
          proxy_ssl_server_name on;

          auth_request /tinyauth;
          error_page 401 = @tinyauth_login;
        '';
      };
    };
    "dns.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
      locations."/" = {
        proxyPass = "http://10.10.10.9:5380";
        proxyWebsockets = true;
        extraConfig = ''
          allow 127.0.0.1/32;
          allow 10.10.10.0/24;
          deny all;
        '';
      };
      locations."= /dns-query" = {
        proxyPass = "http://10.10.10.9:80";
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
        '';
      };
    };
  };
}
