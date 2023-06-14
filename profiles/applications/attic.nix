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
  nix-config = pkgs.writeText "netrc" ''
    machine cache.ataraxiadev.com
    password @token@
  '';
in {
  home-manager.users.${config.mainuser} = {
    home.packages = [ pkgs.attic ];
    nix.settings = {
      substituters = config.nix.settings.substituters;
      trusted-public-keys = config.nix.settings.trusted-public-keys;
      netrc-file = "${homeDir}/.config/nix/netrc";
    };
  };

  secrets.attic-token.services = [ "attic-config" ];
  systemd.services.attic-config = {
    serviceConfig.Type = "oneshot";
    script = ''
      token=$(cat ${token-file})
      mkdir -p ${homeDir}/.config/{nix,attic} > /dev/null 2>&1
      cp ${attic-config} ${homeDir}/.config/attic/config.toml
      cp ${nix-config} ${homeDir}/.config/nix/netrc
      sed -i "s/@token@/$token/" ${homeDir}/.config/attic/config.toml
      sed -i "s/@token@/$token/" ${homeDir}/.config/nix/netrc
      chown -R ${config.mainuser}:users ${homeDir}/.config/{attic,nix}
    '';
    wantedBy = [ "multi-user.target" ];
  };
}
