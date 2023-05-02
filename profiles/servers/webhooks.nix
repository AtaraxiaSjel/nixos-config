{ config, pkgs, lib, ... }:
let
  blog-hook = pkgs.writeShellApplication {
    name = "blog-hook";
    runtimeInputs = with pkgs; [ git hugo openssh go ];
    text = ''
      git pull
      hugo -d ../docroot
    '';
  };
in {
  secrets.webhook-blog.owner = "webhook";

  persist.state.directories = [ "/var/lib/webhook" ];

  users.users.webhook = {
    description = "Webhook daemon user";
    isSystemUser = true;
    group = "webhook";
    createHome = true;
    home = "/var/lib/webhook";
  };

  services.webhook = {
    enable = true;
    port = 9010;
    group = "webhook";
    user = "webhook";
    environmentFiles = [
      config.secrets.webhook-blog.decrypted
    ];
    hooksTemplated = {
      publish-ataraxiadev-blog = ''
        {
          "id": "ataraxiadev-blog",
          "execute-command": "${blog-hook}/bin/blog-hook",
          "command-working-directory": "/srv/http/ataraxiadev.com/gitrepo",
          "trigger-rule":
          {
            "and":
            [
              {
                "match":
                {
                  "type": "payload-hmac-sha256",
                  "secret": "{{ getenv "HOOK_BLOG_SECRET" | js }}",
                  "parameter":
                  {
                    "source": "header",
                    "name": "X-Gitea-Signature"
                  }
                }
              },
              {
                "match":
                {
                  "type": "value",
                  "value": "refs/heads/master",
                  "parameter":
                  {
                    "source": "payload",
                    "name": "ref"
                  }
                }
              }
            ]
          }
        }
      '';
    };
  };

  # services.caddy = {
  #   enable = true;
  #   email = "needed@for.acme";
  #   virtualHosts = {
  #     "${config.networking.hostName}.${config.networking.domain}" = {
  #       extraConfig = ''
  #         route /hooks/* {
  #           # no uri manipulation, path /hooks/ on webhook service as well
  #           reverse_proxy http://localhost:9000;
  #         }
  #       '';
  #     };
  #     "hugo.site" = {
  #       extraConfig = ''
  #         root * /srv/http/ataraxiadev.com/docroot
  #         file_server
  #       '';
  #     };
  #   };
  # };
}