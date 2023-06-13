{ config, pkgs, ... }:
let
  homeDir = config.home-manager.users.${config.mainuser}.home.homeDirectory;
  token-file = config.secrets.attic-token.decrypted;
  attic-config = pkgs.writeText "config.toml" ''
    default-server = "dev"
    [servers.dev]
    endpoint = "https://cache.ataraxiadev.com/"
    token = "@token@"
  '';
in {
  home-manager.users.${config.mainuser}.home.packages = [ pkgs.attic ];

  secrets.attic-token.services = [ "attic-config.service" ];
  systemd.services.attic-config = {
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p ${homeDir}/.config/attic > /dev/null 2>&1
      token=$(cat ${token-file})
      cp ${attic-config} ${homeDir}/.config/attic/config.toml
      sed -i "s/@token@/$token/" ${homeDir}/.config/attic/config.toml
      chown -R ${config.mainuser}:users ${homeDir}/.config/attic
    '';
    wantedBy = [ "multi-user.target" ];
  };
}