{ config, lib, pkgs, inputs, ... }:
let
  home-conf = config.home-manager.users.${config.mainuser};
  config = pkgs.writeText "config.toml" ''
    default-server = "dev"
    [servers.dev]
    endpoint = "https://cache.ataraxiadev.com/"
    token = "@token@"
  '';
in {
  secrets.attic-token.services = [ "attic-config.service" ];

  systemd.user.services.attic-config = rec {
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p ${home-conf.home.homeDirectory}/.config/attic > /dev/null 2>&1
      token=$(cat ${secrets.attic-token.decrypted})
      cp ${config} ${home-conf.home.homeDirectory}/.config/attic/config.toml
      sed -i "/@token@/$token/" ${home-conf.home.homeDirectory}/.config/attic/config.toml
    '';
    wantedBy = [ "default.target" ];
  };
}