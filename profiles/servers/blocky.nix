{ config, pkgs, dnsmasq-list ? [], ... }:
let
  nodeAddress = "192.168.0.5";
  upstream-dns = "100.64.0.1";
in {
  services.headscale-auth.blocky = {
    ephemeral = true;
    outPath = "/tmp/blocky-authkey";
    before = [ "container@blocky.service" ];
  };
  containers.blocky = {
    autoStart = true;
    enableTun = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "${nodeAddress}/24";
    tmpfs = [ "/" ];
    bindMounts."/tmp/blocky-authkey".hostPath = "/tmp/blocky-authkey";
    config = { config, pkgs, lib, ... }:
    let
      grafanaPort = config.services.grafana.settings.server.http_port;
      blockyPort = config.services.blocky.settings.ports.dns;
      blockyHttpPort = config.services.blocky.settings.ports.http;
    in {
      networking = {
        defaultGateway = "192.168.0.1";
        hostName = "blocky-node";
        nameservers = [ "127.0.0.1" ];
        enableIPv6 = false;
        useHostResolvConf = false;
        firewall = {
          enable = true;
          allowedTCPPorts = [ blockyPort grafanaPort ];
          allowedUDPPorts = [ blockyPort ];
        };
        hosts = {
          "192.168.0.10" = [ "wg.ataraxiadev.com" ];
        };
      };
      # ephemeral tailscale node
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
        authKeyFile = "/tmp/blocky-authkey";
        extraUpFlags = [
          "--login-server=https://wg.ataraxiadev.com"
          "--accept-dns=false"
          "--advertise-exit-node=false"
        ];
      };
      systemd.services.tailscaled.serviceConfig.Environment = let
        cfg = config.services.tailscale;
      in lib.mkForce [
        "PORT=${toString cfg.port}"
        ''"FLAGS=--tun ${lib.escapeShellArg cfg.interfaceName} --state=mem:"''
      ];

      services.dnsmasq = {
        enable = true;
        alwaysKeepRunning = true;
        resolveLocalQueries = false;
        settings = {
          port = 5353;
          no-resolv = true;
          no-hosts = true;
          listen-address = "127.0.0.1";
          no-dhcp-interface = "";
          address = dnsmasq-list ++ [];
        };
      };
      services.blocky = {
        enable = true;
        settings = {
          upstream.default = [ upstream-dns ];
          upstreamTimeout = "10s";
          blocking = {
            blackLists.telemetry = [ ../../misc/telemetry.hosts ];
            clientGroupsBlock.default = [ "telemetry" ];
          };
          conditional = {
            fallbackUpstream = true;
            mapping = {
              "ataraxiadev.com" = "127.0.0.1:5353";
            };
          };
          # drop ipv6 requests
          filtering.queryTypes = [ "AAAA" ];
          caching = {
            minTime = "0m";
            maxTime = "12h";
            cacheTimeNegative = "1m";
            prefetching = true;
          };
          ports = {
            dns = 53;
            http = "127.0.0.1:4000";
          };
          prometheus.enable = true;
          queryLog.type = "console";
        };
      };
      services.prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        globalConfig.scrape_interval = "15s";
        globalConfig.evaluation_interval = "15s";
        scrapeConfigs = [{
          job_name = "blocky";
          static_configs = [{
            targets = [ blockyHttpPort ];
          }];
        }];
      };
      services.grafana = {
        enable = true;
        settings = {
          analytics.reporting_enabled = false;
          server = {
            domain = "${nodeAddress}:${toString grafanaPort}";
            http_addr = nodeAddress;
            enable_gzip = true;
          };
          panels.disable_sanitize_html = true;
        };
        provision = {
          enable = true;
          datasources.settings = {
            datasources = [{
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              orgId = 1;
              uid = "Y4SSG429DWCGDQ3R";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
              isDefault = true;
              jsonData = {
                graphiteVersion = "1.1";
                tlsAuth = false;
                tlsAuthWithCACert = false;
              };
              version = 1;
              editable = true;
            }];
          };
          dashboards = {
            settings = {
              providers = [{
                name = "My Dashboards";
                options.path = "/etc/grafana-dashboards";
              }];
            };
          };
        };
      };
      environment.etc = {
        "grafana-dashboards/blocky_rev3.json" = {
          source = ../../misc/grafana_blocky_rev3.json;
          group = "grafana";
          user = "grafana";
        };
      };
      system.stateVersion = "23.11";
    };
  };
}