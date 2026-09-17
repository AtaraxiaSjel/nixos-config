{
  config,
  lib,
  useHomeManager,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.vpn.amnezia-vpn;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.vpn.amnezia-vpn = {
    enable = mkEnableOption "Enable amnezia-vpn program";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "amneziawg" ];
    boot.extraModulePackages = with config.boot.kernelPackages; [ amneziawg ];

    programs.amnezia-vpn.enable = true;

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        persist.state.directories = [ ".config/AmneziaVPN.ORG" ];
      };
    };
  };
}
