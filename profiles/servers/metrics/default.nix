{ config, pkgs, inputs, ... }:
let
  promStateDir = "prometheus2";
  grafanaDataDir = "grafana";
  prometheusUid = "d8e758af-3f6b-4891-a855-1efe6cdec658";
  blockyUrl = "10.10.10.53:4000";
  prometheusPort = 9001;
  grafanaPort = 9002;

  secretCfg = {
    sopsFile = inputs.self.secretsDir + /home-hypervisor/metrics.yaml;
    owner = "grafana";
  };
in
{
  imports = [ inputs.ataraxiasjel-nur.nixosModules.prometheus-exporters ];
  sops.secrets.grafana-oidc-id = secretCfg;
  sops.secrets.grafana-oidc-secret = secretCfg;

  services.prometheus = {
    enable = true;
    stateDir = promStateDir;
    listenAddress = "127.0.0.1";
    port = prometheusPort;
    globalConfig.scrape_interval = "15s";
    globalConfig.evaluation_interval = "15s";
    exporters = {
      podman = {
        enable = true;
        enabledCollectors = [ "enable-all" ];
        port = 9012;
      };
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9010;
      };
      zfs = {
        enable = true;
        port = 9011;
      };
    };
    scrapeConfigs = [
      {
        job_name = "blocky";
        static_configs = [ { targets = [ blockyUrl ]; } ];
      }
      {
        job_name = "podman";
        static_configs = [
          { targets = [ "localhost:${toString config.services.prometheus.exporters.podman.port}" ]; }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          { targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }
        ];
      }
      {
        job_name = "zfs";
        static_configs = [
          { targets = [ "localhost:${toString config.services.prometheus.exporters.zfs.port}" ]; }
        ];
      }
    ];
  };
  services.grafana = {
    enable = true;
    dataDir = "/var/lib/${grafanaDataDir}";
    declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];
    settings = {
      auth = {
        signout_redirect_url = "https://auth.ataraxiadev.com/application/o/grafana/end-session/";
        oauth_auto_login = true;
      };
      "auth.generic_oauth" = {
        name = "authentik";
        enabled = "true";
        client_id = "$__file{${config.sops.secrets.grafana-oidc-id.path}}";
        client_secret = "$__file{${config.sops.secrets.grafana-oidc-secret.path}}";
        scopes = "openid email profile";
        auth_url = "https://auth.ataraxiadev.com/application/o/authorize/";
        token_url = "https://auth.ataraxiadev.com/application/o/token/";
        api_url = "https://auth.ataraxiadev.com/application/o/userinfo/";
        role_attribute_path = "contains(groups, 'grafanaAdmins') && 'Admin' || contains(groups, 'grafanaEditors') && 'Editor' || 'Viewer'";
      };
      users.auto_assign_org = true;
      users.auto_assign_org_id = 1;
      analytics.reporting_enabled = false;
      server = {
        domain = "stats.ataraxiadev.com";
        http_addr = "127.0.0.1";
        http_port = grafanaPort;
        root_url = "https://%(domain)s/";
        enable_gzip = true;
      };
      panels.disable_sanitize_html = true;
    };
    provision = {
      enable = true;
      datasources.settings = {
        datasources = [
          {
            name = "Prometheus ${config.networking.hostName}";
            type = "prometheus";
            access = "proxy";
            orgId = 1;
            uid = prometheusUid;
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
            jsonData = {
              httpMethod = "POST";
              manageAlerts = true;
              prometheusType = "Prometheus";
              prometheusVersion = config.services.prometheus.package.version;
              cacheLevel = "High";
            };
            editable = false;
          }
        ];
      };
      dashboards = {
        settings = {
          providers = [
            {
              name = "Dashboards";
              # folder = "Services";
              options.path = import ./dashboards {
                inherit pkgs prometheusUid;
                blockyUrl = "http://${blockyUrl}";
              };
            }
          ];
        };
      };
    };
  };

  persist.state.directories = [
    "/var/lib/${promStateDir}"
    "/var/lib/${grafanaDataDir}"
  ];
}
