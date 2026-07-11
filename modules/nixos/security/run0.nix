{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.run0;
in
{
  options.ataraxia.defaults.run0 = {
    enable = mkEnableOption "Use run0 by default";
    doas-fallback = {
      enable = (mkEnableOption "Enable fallback to doas for `deploy` user") // {
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    security.sudo.enable = false;
    security.run0.enableSudoAlias = true;
    # security.run0.persistentAuth.enable = true;

    security.doas = mkIf cfg.doas-fallback.enable {
      enable = true;
      extraRules = [
        {
          users = [ "deploy" ];
          noPass = true;
          keepEnv = true;
        }
      ];
    };
  };
}
