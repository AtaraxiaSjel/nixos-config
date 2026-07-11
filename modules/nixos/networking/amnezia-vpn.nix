{
  config,
  lib,
  pkgs,
  useHomeManager,
  flake-self,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.strings) versionOlder;
  cfg = config.ataraxia.vpn.amnezia-vpn;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.vpn.amnezia-vpn = {
    enable = mkEnableOption "Enable amnezia-vpn program";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "amneziawg" ];

    programs.amnezia-vpn.enable = true;

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        persist.state.directories = [ ".config/AmneziaVPN.ORG" ];
      };
    };
  };
}
