{ config, dns-mapping ? {}, ... }:
let
  nodeAddress = "192.168.0.5";
  wgAddress = "10.100.0.1";
  wgConf = config.secrets.wg-hypervisor-dns.decrypted;
in {
  boot.kernelModules = [ "wireguard" ];
  secrets.wg-hypervisor-dns.services = [ "container@blocky.service" ];
  containers.blocky = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "${nodeAddress}/24";
    tmpfs = [ "/" ];
    bindMounts."/var/secrets/${wgConf}" = {
      hostPath = wgConf;
      isReadOnly = true;
    };
    config = { config, pkgs, ... }:
    let
      grafanaPort = config.services.grafana.settings.server.http_port;
      blockyPort = config.services.blocky.settings.port;
    in {
      networking = {
        defaultGateway = "192.168.0.1";
        hostName = "blocky-node";
        nameservers = [];
        enableIPv6 = false;
        useHostResolvConf = false;
        firewall = {
          enable = true;
          allowedTCPPorts = [ blockyPort grafanaPort ];
          allowedUDPPorts = [ blockyPort ];
        };

        wg-quick.interfaces.wg0.configFile = "/var/secrets/${wgConf}";
      };
      services.blocky = {
        enable = true;
        settings = {
          upstream.default = [ wgAddress ];
          upstreamTimeout = "15s";
          caching = {
            minTime = "0m"; # TTL
            maxTime = "12h";
            cacheTimeNegative = "1m";
            prefetching = true;
          };
          port = 53;
          httpPort = "127.0.0.1:4000";
          prometheus.enable = true;
          queryLog.type = "console";
        } // dns-mapping;
      };
      services.prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        globalConfig.scrape_interval = "15s";
        globalConfig.evaluation_interval = "15s";
        scrapeConfigs = [{
          job_name = "blocky";
          static_configs = [{
            targets = [ config.services.blocky.settings.httpPort ];
          }];
        }];
      };
      services.grafana = {
        enable = true;
        settings = {
          analytics.reporting_enabled = false;
          server = rec {
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
      system.stateVersion = "23.05";
    };
  };
}