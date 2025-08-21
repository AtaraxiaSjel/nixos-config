{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) int;

  cfg = config.ataraxia.services.tor;
in
{
  options.ataraxia.services.tor = {
    enable = mkEnableOption "Enable tor service client";
    enableRelay = mkEnableOption "Enable tor service bridge";
    relayPort = mkOption {
      type = int;
      description = "Bridge listen port";
    };
  };

  config = mkIf (cfg.enable || cfg.enableRelay) {
    services.tor = {
      enable = true;
      client.enable = cfg.enable;
      relay.enable = cfg.enableRelay;
      relay.role = "private-bridge";
      settings = mkIf cfg.enableRelay {
        ContactInfo = "admin@ataraxiadev.com";
        Nickname = config.networking.hostName;
        ORPort = 42891;
        ServerTransportListenAddr = "obfs4 0.0.0.0:${toString cfg.relayPort}";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.relayPort ];

    persist.state.directories = [ "/var/lib/tor" ];
  };
}
