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

  awg = config.boot.kernelPackages.amneziawg;
  amneziawg =
    if versionOlder awg.version "1.0.20260210" then
      (awg.overrideAttrs (oa: {
        version = "1.0.20260210";
        src = pkgs.fetchFromGitHub {
          owner = "amnezia-vpn";
          repo = "amneziawg-linux-kernel-module";
          tag = "v1.0.20260210";
          hash = "sha256-w2TK0dE4fhEAgfaMKwaadVgle4cGEigQNHmXLkpxERA=";
        };
        patches = oa.patches or [ ] ++ [ (flake-self + /patches/amnezia-fix.patch) ];
      }))
    else
      awg;
in
{
  options.ataraxia.vpn.amnezia-vpn = {
    enable = mkEnableOption "Enable amnezia-vpn program";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "amneziawg" ];
    # TODO: remove after merged in upstream nixpkgs
    boot.extraModulePackages = [ amneziawg ];

    programs.amnezia-vpn.enable = true;

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        persist.state.directories = [ ".config/AmneziaVPN.ORG" ];
      };
    };
  };
}
