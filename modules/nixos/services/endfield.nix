{
  config,
  lib,
  inputs,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.services.endfield-daily;
in
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.endfield ];

  options.ataraxia.services.endfield-daily = {
    enable = mkEnableOption "Enable endfield-daily service";
  };

  config = mkIf cfg.enable {
    sops.secrets.endfield-config.sopsFile = secretsDir + /misc.yaml;
    services.endfield-daily = {
      enable = true;
      configFile = config.sops.secrets.endfield-config.path;
      startAt = "*-*-* 20:00:00";
    };
  };
}
