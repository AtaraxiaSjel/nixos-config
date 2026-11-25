{
  config,
  lib,
  inputs,
  useHomeManager,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.ataraxia.services.lanotifica;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.lanotifica ];

  options.ataraxia.services.lanotifica = {
    enable = mkEnableOption "Enable lanotifica service";
  };

  config = mkIf cfg.enable {
    services.lanotifica = {
      enable = true;
      openFirewall = true;
    };
    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        persist.state.directories = [ ".config/lanotifica" ];
      };
    };
  };
}
