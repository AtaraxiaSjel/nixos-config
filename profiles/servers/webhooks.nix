{ config, pkgs, inputs, ... }:
let
  blog-hook = pkgs.writeShellApplication {
    name = "blog-hook";
    runtimeInputs = with pkgs; [ git hugo openssh go ];
    text = ''
      if [ ! -d ".git" ]; then
        git init -b master && \
            git remote add origin https://code.ataraxiadev.com/AtaraxiaDev/ataraxiadev-blog.git && \
            git fetch && \
            git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/master && \
            git reset --hard origin/master && \
            git branch --set-upstream-to=origin/master
      else
        git fetch origin master
        git reset --hard origin/master
      fi
      hugo -d ../docroot
    '';
  };
in {
  sops.secrets.webhook-env.sopsFile = inputs.self.secretsDir + /home-hypervisor/webhooks.yaml;
  sops.secrets.webhook-env.owner = "webhook";
  sops.secrets.webhook-env.restartUnits = [ "webhook.service" ];

  systemd.tmpfiles.rules = [
    "d /srv/http/ataraxiadev.com/gitrepo 0755 webhook acme -"
  ];

  persist.state.directories = [ "/var/lib/webhook" ];

  users.users.webhook = {
    description = "Webhook daemon user";
    isSystemUser = true;
    group = "webhook";
    createHome = true;
    home = "/var/lib/webhook";
  };

  systemd.services.webhook.serviceConfig.EnvironmentFile = config.sops.secrets.webhook-env.path;
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
