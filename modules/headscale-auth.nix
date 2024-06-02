{ config, lib, pkgs, inputs, ... }:
with lib;
{
  options.services.headscale-auth = mkOption {
    description = ''
      Request headscale auth key.
    '';
    type = types.attrsOf (types.submodule ({ ... }: {
      options = {
        autoStart = mkOption {
          type = types.bool;
          default = false;
          description = "Request auth key on startup.";
        };
        ephemeral = mkOption {
          type = types.bool;
          default = false;
          description = "Request ephemeral auth key.";
        };
        expire = mkOption {
          type = types.str;
          default = "1h";
          description = "Auth key expiration time.";
        };
        user = mkOption {
          type = types.str;
          default = "ataraxiadev";
          description = "Auth key user.";
        };
        outPath = mkOption {
          type = types.str;
          default = "/tmp/auth-key";
          description = "Where to write down the auth key.";
        };
        before = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = "Start service before this services.";
        };
      };
    }));
    default = { };
  };
  config = mkIf (config.services.headscale-auth != { }) {
    sops.secrets.headscale-api-env.sopsFile = inputs.self.secretsDir + /misc.yaml;

    systemd.services =
      mapAttrs'
        (name: cfg: nameValuePair "headscale-auth-${name}" ({
          path = [ pkgs.headscale pkgs.jq ];
          restartIfChanged = false;
          requiredBy = cfg.before;
          before = cfg.before;
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = mkIf cfg.autoStart [ "multi-user.target" ];
          environment = {
            HEADSCALE_CLI_ADDRESS = "wg.ataraxiadev.com:443";
          };
          script = ''
            while true; do
              auth_key=$(headscale preauthkeys create -e ${cfg.expire} -u ${cfg.user} -o json ${optionalString cfg.ephemeral "--ephemeral"} | jq -r .key)
              [[ "$auth_key" = "null" ]] || break
              echo "Cannot retrieve auth key. Will try again after 5 seconds." >&2
              sleep 5
            done
            echo $auth_key > "${cfg.outPath}"
          '';
          serviceConfig = {
            EnvironmentFile = config.sops.secrets.headscale-api-env.path;
            Type = "oneshot";
          };
        })
      ) config.services.headscale-auth;
  };
}