{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    mkOption
    recursiveUpdate
    ;
  inherit (lib.types) bool;
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.services.rustdesk;
  nginx = config.ataraxia.services.nginx;
  domain = "desk.ataraxiadev.com";
in
{
  options.ataraxia.services.rustdesk = {
    enable = mkEnableOption "Enable rustdesk service";
    nginxHost = mkOption {
      type = bool;
      default = config.ataraxia.services.nginx.enable;
      description = "Enable nginx vHost integration";
    };
  };

  config = mkIf cfg.enable {
    services.rustdesk-server = {
      enable = true;
      openFirewall = true;
      relay.enable = true;
      signal.enable = true;
      signal.relayHosts = [ domain ];
    };

    networking.hosts = {
      "127.0.0.1" = [ domain ];
    };

    systemd.services.rustdesk-relay.serviceConfig.DynamicUser = mkForce false;
    systemd.services.rustdesk-signal.serviceConfig.DynamicUser = mkForce false;

    services.nginx.virtualHosts = mkIf cfg.nginxHost {
      ${domain} = recursiveUpdate nginx.defaultSettings {
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:${ports.rustdesk.str}/";
          };
          "/ws/id" = {
            proxyPass = "http://127.0.0.1:${ports.rustdesk-id.str}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_read_timeout 120s;
            '';
          };
          "/ws/relay" = {
            proxyPass = "http://127.0.0.1:${ports.rustdesk-relay.str}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_read_timeout 120s;
            '';
          };
        };
      };
    };

    persist.state.directories = [ "/var/lib/rustdesk" ];
  };
}
