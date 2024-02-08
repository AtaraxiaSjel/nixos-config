{ config, pkgs, inputs, ... }:
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
  sops.secrets.webhook-blog.sopsFile = inputs.self.secretsDir + /home-hypervisor/webhooks.yaml;
  sops.secrets.webhook-blog.owner = "webhook";
  sops.secrets.webhook-blog.restartUnits = [ "webhook.service" ];

  persist.state.directories = [ "/var/lib/webhook" ];

  users.users.webhook = {
    description = "Webhook daemon user";
    isSystemUser = true;
    group = "webhook";
    createHome = true;
    home = "/var/lib/webhook";
  };

  systemd.services.webhook.serviceConfig.EnvironmentFile = config.sops.secrets.webhook-blog.path;
  services.webhook = {
    enable = true;
    port = 9510;
    group = "webhook";
    user = "webhook";
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
}
