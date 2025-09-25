{
  config,
  lib,
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

  services.nginx.virtualHosts = {
    "incus.ataraxiadev.com" = recursiveUpdate nginx.tinyauthSettings {
      locations."/" = {
        proxyPass = "https://10.10.10.5:8443";
        proxyWebsockets = true;
        extraConfig = ''
          auth_request /tinyauth;
          error_page 401 = @tinyauth_login;
        '';
      };
    };
    "dns.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
      locations."/" = {
        proxyPass = "http://10.10.10.9:8080";
      };
    };
  };
}
