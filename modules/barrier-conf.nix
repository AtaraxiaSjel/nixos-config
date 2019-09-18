{ config, lib, pkgs, ... }:
with lib;
let
  cfgC = config.services.barrier.client;
  cfgS = config.services.barrier.server;
in
{
  options = {
    services.barrier = {
      client = {
        enable = mkOption {
          default = false;
          description = "
            Whether to enable the Barrier client (receive keyboard and mouse events from a Barrier server).
          ";
        };
        screenName = mkOption {
          default = "";
          description = ''
            Use the given name instead of the hostname to identify
            ourselves to the server.
          '';
        };
        serverAddress = mkOption {
          description = ''
            The server address is of the form: [hostname][:port].  The
            hostname must be the address or hostname of the server.  The
            port overrides the default port, 24800.
          '';
        };
        autoStart = mkOption {
          default = true;
          type = types.bool;
          description = "Whether the Barrier client should be started automatically.";
        };
      };

      server = {
        enable = mkOption {
          default = false;
          description = ''
            Whether to enable the Barrier server (send keyboard and mouse events).
          '';
        };
        configFile = mkOption {
          default = "/etc/barrier-server.conf";
          description = "The Barrier server configuration file.";
        };
        screenName = mkOption {
          default = "";
          description = ''
            Use the given name instead of the hostname to identify
            this screen in the configuration.
          '';
        };
        address = mkOption {
          default = "";
          description = "Address on which to listen for clients.";
        };
        autoStart = mkOption {
          default = true;
          type = types.bool;
          description = "Whether the Barrier server should be started automatically.";
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfgC.enable {
      systemd.user.services."barrier-client" = {
        after = [ "network.target" "graphical-session.target" ];
        description = "Barrier client";
        wantedBy = optional cfgC.autoStart "graphical-session.target";
        path = [ pkgs.barrier ];
        serviceConfig.ExecStart = ''${pkgs.barrier}/bin/barrierc -f ${optionalString (cfgC.screenName != "") "-n ${cfgC.screenName}"} ${cfgC.serverAddress}'';
        serviceConfig.Restart = "on-failure";
      };
    })
    (mkIf cfgS.enable {
      systemd.user.services."barrier-server" = {
        after = [ "network.target" "graphical-session.target" ];
        description = "Barrier server";
        wantedBy = optional cfgS.autoStart "graphical-session.target";
        path = [ pkgs.barrier ];
        serviceConfig.ExecStart = ''${pkgs.barrier}/bin/barriers -c ${cfgS.configFile} -f ${optionalString (cfgS.address != "") "-a ${cfgS.address}"} ${optionalString (cfgS.screenName != "") "-n ${cfgS.screenName}" }'';
        serviceConfig.Restart = "on-failure";
      };
    })
  ];
}