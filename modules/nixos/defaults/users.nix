{ lib, ... }:
let
  inherit (lib) mapAttrs mkOption;
  inherit (lib.types) attrsOf int;
in
{
  options.ataraxia.lists.users = mkOption {
    type = attrsOf int;
    default = { };
    description = "List of users for various services and containers";
    apply = mapAttrs (
      name: uid: {
        inherit name uid;
        gid = uid;
        uidStr = toString uid;
        gidStr = toString uid;
      }
    );
  };

  config = {
    ataraxia.lists.users = {
      lldap = 391;
      pocket-id = 390;
      tinyauth = 392;
      singbox = 393;
      uptime-kuma = 394;
      tuwunel = 395;
      hass-oci = 396;
    };
  };
}
