{ pkgs, config, lib, ... }:
with lib;
with types;
let
  mkCredOption = service: extra:
  mkOption {
    description = "Credentials for ${service}";
    type = nullOr (submodule {
      options = {
        user = mkOption {
          type = string;
          description = "Username for ${service}";
        };
        password = mkOption {
          type = string;
          description = "Password for ${service}";
        };
      } // extra;
    });
  };
in rec {
  options.secrets = {
    wireguard = mkOption {
      type = attrs;
      description = "Wireguard conf";
    };
    windows-samba = mkCredOption "samba on windows" { };
    linux-samba = mkCredOption "samba on linux" { };
    spotify = mkCredOption "Spotify" { };
  };
  config = let
    secretnix = import ../secret.nix;
    secrets = if isNull secretnix then
      mapAttrs (n: v: null) options.secrets
    else
      secretnix;
  in { inherit secrets; };
}
