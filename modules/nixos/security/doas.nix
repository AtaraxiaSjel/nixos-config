{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.doas;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.defaults.doas = {
    enable = mkEnableOption "Use doas by default";
  };

  config = mkIf cfg.enable {
    users.allowNoPasswordLogin = true;
    security.sudo.enable = false;
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [ defaultUser ];
          keepEnv = true;
          persist = true;
        }
        {
          users = [ "deploy" ];
          noPass = true;
          keepEnv = true;
        }
      ];
    };
    environment.systemPackages = [ pkgs.doas-sudo-shim ];
  };
}
