{ lib, ... }:
let
  inherit (lib) mapAttrs mkOption;
  inherit (lib.types) attrsOf port;
in
{
  options.ataraxia.lists.ports = mkOption {
    type = attrsOf port;
    default = { };
    description = "List of ports for various services and containers";
    apply = mapAttrs (
      _name: p: {
        int = p;
        str = toString p;
      }
    );
  };

  config = {
    ataraxia.lists.ports = {
      docker-socket-proxy = 2375;
      filestash = 8334;
      forgejo = 6000;
      headscale = 8005;
      headscale-grpc = 50443;
      home-assistant = 8123;
      inpx-web = 12380;
      kiwix = 8030;
      lldap-web = 6100;
      ntfy-sh = 2586;
      pocket-id = 1411;
      rustdesk = 21114;
      rustdesk-id = 21118;
      rustdesk-relay = 21119;
      singbox = 2080;
      singbox-panel = 9090;
      slskd = 5030;
      slskd-soulseek = 50300;
      suwayomi = 3200;
      tinyauth = 3100;
      tor = 9150;
      tor-dns = 8853;
      uptime-kuma = 3110;
      vaultwarden = 8812;
      vaultwarden-ws = 3012;

      jellyfin = 8011;
      kavita = 8015;
      sonarr = 8012;
      radarr = 8013;
      lidarr = 8014;
      medusa = 8016;
      qbittorrent = 8010;
      prowlarr = 8018;
      navidrome = 4533;
      tubearchivist = 8017;
    };
  };
}
