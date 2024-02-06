{ config, lib, pkgs, inputs, ... }: {
  sops.secrets.office-jwt-secret.sopsFile = inputs.self.secretsDir + /home-hypervisor/onlyoffice.yaml;
  sops.secrets.office-jwt-secret.owner = "onlyoffice";

  services.onlyoffice = {
    enable = true;
    port = 8800;
    hostname = "office.ataraxiadev.com";
    jwtSecretFile = config.sops.secrets.office-jwt-secret.path;
  };

  persist.state.directories = [ "/var/lib/onlyoffice" ];

  services.nginx = let
    cfg = config.services.onlyoffice;
  in {
    virtualHosts."office.ataraxiadev.com" = {
      useACMEHost = "ataraxiadev.com";
      enableACME = false;
      forceSSL = true;
      locations = {
        # /etc/nginx/includes/ds-docservice.conf
        "~ ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(web-apps\/apps\/api\/documents\/api\.js)$".extraConfig = ''
          expires -1;
          alias ${cfg.package}/var/www/onlyoffice/documentserver/$2;
        '';
        "~ ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(web-apps)(\/.*\.json)$".extraConfig = ''
          expires 365d;
          error_log /dev/null crit;
          alias ${cfg.package}/var/www/onlyoffice/documentserver/$2$3;
        '';
        "~ ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(sdkjs-plugins)(\/.*\.json)$".extraConfig = ''
          expires 365d;
          error_log /dev/null crit;
          alias ${cfg.package}/var/www/onlyoffice/documentserver/$2$3;
        '';
        "~ ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(web-apps|sdkjs|sdkjs-plugins|fonts)(\/.*)$".extraConfig = ''
          expires 365d;
          alias ${cfg.package}/var/www/onlyoffice/documentserver/$2$3;
        '';
        "~* ^(\/cache\/files.*)(\/.*)".extraConfig = ''
          alias /var/lib/onlyoffice/documentserver/App_Data$1;
          add_header Content-Disposition "attachment; filename*=UTF-8''$arg_filename";

          set $secret_string verysecretstring;
          secure_link $arg_md5,$arg_expires;
          secure_link_md5 "$secure_link_expires$uri$secret_string";

          if ($secure_link = "") {
            return 403;
          }

          if ($secure_link = "0") {
            return 410;
          }
        '';
        "~* ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(internal)(\/.*)$".extraConfig = ''
          allow 127.0.0.1;
          deny all;
          proxy_pass http://127.0.0.1:${toString cfg.port}/$2$3;
        '';
        "~* ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(info)(\/.*)$".extraConfig = ''
          allow 127.0.0.1;
          deny all;
          proxy_pass http://127.0.0.1:${toString cfg.port}/$2$3;
        '';
        "/".extraConfig = ''
          proxy_pass http://127.0.0.1:${toString cfg.port};
        '';
        "~ ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?(\/doc\/.*)".extraConfig = ''
          proxy_pass http://127.0.0.1:${toString cfg.port}$2;
          proxy_http_version 1.1;
        '';
        "/${cfg.package.version}/".extraConfig = ''
          proxy_pass http://127.0.0.1:${toString cfg.port}/;
        '';
        "~ ^(\/[\d]+\.[\d]+\.[\d]+[\.|-][\d]+)?\/(dictionaries)(\/.*)$".extraConfig = ''
          expires 365d;
          alias ${cfg.package}/var/www/onlyoffice/documentserver/$2$3;
        '';
        # /etc/nginx/includes/ds-example.conf
        "~ ^(\/welcome\/.*)$".extraConfig = ''
          expires 365d;
          alias ${cfg.package}/var/www/onlyoffice/documentserver-example$1;
          index docker.html;
        '';
      };
      extraConfig = ''
        rewrite ^/$ /welcome/ redirect;
        rewrite ^\/OfficeWeb(\/apps\/.*)$ /${cfg.package.version}/web-apps$1 redirect;
        rewrite ^(\/web-apps\/apps\/(?!api\/).*)$ /${cfg.package.version}$1 redirect;

        # based on https://github.com/ONLYOFFICE/document-server-package/blob/master/common/documentserver/nginx/includes/http-common.conf.m4#L29-L34
        # without variable indirection and correct variable names
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        # required for CSP to take effect
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # required for websocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
      '';
    };
  };
}