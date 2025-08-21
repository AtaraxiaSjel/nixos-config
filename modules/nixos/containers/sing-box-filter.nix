{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.virtualisation.quadlet) networks;

  cfg = config.ataraxia.containers.sing-box-filter;

  # Exclude almost all european countries (and some more)
  filter-countries = "!EU,!AL,!AD,!BY,!BA,!GB,!CH,!IS,!LI,!MD,!MC,!ME,!MK,!NO,!RU,!SM,!RS,!UA,!VA,!XK,!US,!CN,!IR,!PK";
  filter-protocols = "vless,ss";
  geoip-db = "https://git.io/GeoLite2-Country.mmdb";
  proxy-list = "https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main/V2Ray-Config-By-EbraSha.txt";
  dockerfile = pkgs.writeText "Dockerfile.sing-box" ''
    ARG sing_box_ver="1.12.1"
    ARG alpine_ver="3.22"
    ARG processor_ver="0.1.1"

    FROM ghcr.io/sagernet/sing-box:v''${sing_box_ver} AS sing-box
    FROM ataraxiadev/proxy-processor:''${processor_ver} as proxy-filter

    FROM alpine:''${alpine_ver}
    COPY --from=sing-box /usr/local/bin/sing-box /bin/sing-box
    COPY --from=proxy-filter /bin/proxy-filter-cli /bin/proxy-filter-cli
    WORKDIR /app
    ENTRYPOINT ["/app/entrypoint.sh"]
  '';
  entrypoint = pkgs.writeScript "singbox-entrypoint" ''
    #!/bin/ash
    set -euo pipefail

    mkdir -p /etc/sing-box
    mkdir -p /var/lib/sing-box
    cp /app/sing-box.json /etc/sing-box/config.json

    echo "0 * * * * /app/update.sh" > /var/spool/cron/crontabs/root
    /app/update.sh &
    crond -f
  '';
  sing-box-update = pkgs.writeScript "singbox-update" ''
    #!/bin/ash
    set -euo pipefail

    if [ $(pgrep "update.sh" | wc -l) -gt 2 ]; then
        exit 0
    fi
    echo "Update proxy list..."
    proxy-filter-cli -i ${proxy-list} -o outbounds.json --geoip ${geoip-db} -t ${filter-protocols} -c '${filter-countries}' -f sing-box
    cp outbounds.json /etc/sing-box/outbound.json
    echo "Update proxy list finished..."
    if pgrep "sing-box"; then
        echo "Stopping sing-box process..."
        pkill -f sing-box
    fi
    echo "Starting sing-box process..."
    sing-box -D /var/lib/sing-box -C /etc/sing-box run &
  '';
  singbox-config = pkgs.writeText "singbox-entrypoint" ''
    {
      "log": {
        "level": "warn",
        "timestamp": true
      },
      "dns": {
        "strategy": "ipv4_only",
        "disable_cache": true,
        "disable_expire": true,
        "servers": [{
          "tag": "local-dns",
          "type": "udp",
          "server": "10.10.10.1"
        }]
      },
      "inbounds": [{
        "type": "mixed",
        "tag": "mixed-in",
        "domain_strategy": "ipv4_only",
        "listen": "0.0.0.0",
        "listen_port": 2080,
        "tcp_fast_open": false
      }],
      "outbounds": [{
        "type": "direct",
        "tag": "direct-out"
      }],
      "route": {
        "rules": [{
          "action": "resolve",
          "strategy": "prefer_ipv4"
        }, {
          "action": "sniff"
        }, {
          "protocol": "dns",
          "action": "hijack-dns"
        }, {
          "outbound": "direct-out",
          "ip_is_private": true
        }],
        "final": "urltest-out",
        "auto_detect_interface": true
      },
      "experimental": {
        "clash_api": {
          "external_controller": "0.0.0.0:9090",
          "external_ui": "ui",
          "external_ui_download_url": "https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip",
          "external_ui_download_detour": "direct-out"
        },
        "cache_file": {
          "enabled": true
        }
      }
    }
  '';
in
{
  options.ataraxia.containers.sing-box-filter = {
    enable = mkEnableOption "Enable sing-box-filter container";
  };

  config = mkIf cfg.enable {
    virtualisation.quadlet = {
      builds.sing-box-filter = {
        autoStart = true;
        buildConfig = {
          file = toString dockerfile;
          tag = "sing-box-filter:latest";
          # globalArgs = [ "--build-args=" ];
        };
      };
      containers.sing-box-filter = {
        autoStart = true;
        containerConfig = {
          image = config.virtualisation.quadlet.builds.sing-box-filter.ref;
          networks = [ networks.br-services.ref ];
          publishPorts = [
            "0.0.0.0:2080:2080/tcp"
            "0.0.0.0:2081:9090/tcp"
          ];
          volumes = [
            "${entrypoint}:/app/entrypoint.sh:ro"
            "${sing-box-update}:/app/update.sh:ro"
            "${singbox-config}:/app/sing-box.json:ro"
          ];
        };
      };
    };
    networking.firewall.allowedTCPPorts = [
      2080
      2081
    ];
  };
}
