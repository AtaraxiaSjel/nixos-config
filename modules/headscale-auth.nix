{ config, lib, pkgs, inputs, ... }:
with lib;
{
  options.services.headscale-auth = mkOption {
    description = mdDoc ''
      Request headscale auth key.
    '';
    type = types.attrsOf (types.submodule ({ cfg, name, ... }: {
      options = {
        autoStart = mkOption {
          type = types.bool;
          default = false;
          description = mdDoc "Request auth key on startup.";
        };
        ephemeral = mkOption {
          type = types.bool;
          default = false;
          description = mdDoc "Request ephemeral auth key.";
        };
        expire = mkOption {
          type = types.str;
          default = "1h";
          description = mdDoc "Auth key expiration time.";
        };
        user = mkOption {
          type = types.str;
          default = "ataraxiadev";
          description = mdDoc "Auth key user.";
        };
        outPath = mkOption {
          type = types.str;
          default = "/tmp/auth-key";
          description = mdDoc "Where to write down the auth key.";
        };
        before = mkOption {
          type = with types; listOf str;
          default = [ ];
          description = mdDoc "Start service before this services.";
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
            auth_key=$(headscale preauthkeys create -e ${cfg.expire} -u ${cfg.user} -o json ${optionalString cfg.ephemeral "--ephemeral"} | jq -r .key)
            if [ "$auth_key" = "null" ]; then
              echo "Cannot retrieve auth key." >&2
              exit 1
            else
              echo $auth_key > "${cfg.outPath}"
            fi
          '';
          serviceConfig = {
            EnvironmentFile = config.sops.secrets.headscale-api-env.path;
            Type = "oneshot";
          };
        })
      ) config.services.headscale-auth;
  };
}