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
      pocket-id = 390;
      lldap = 391;
      tinyauth = 392;
      singbox = 393;
      uptime-kuma = 394;
      tuwunel = 395;
      hass-oci = 396;
      slskd = 397;
      searx = 398;
      vaultwarden = 399;
      # 400 and up are reserved, so start over
      forgejo = 350;
      headscale = 351;
      ntfy-sh = 352;
      rustdesk = 353;
      suwayomi = 354;
    };
  };
}
