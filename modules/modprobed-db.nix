{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkPackageOption mkIf;

  cfg = config.services.modprobed-db;
in
{
  options = {
    services.modprobed-db = {
      enable = mkEnableOption "modprobed-db service to scan and store new kernel modules";
      package = mkPackageOption pkgs "modprobed-db" { };
    };
  };

  config = mkIf cfg.enable {
    systemd.user = {
      services.modprobed-db = {
        description = "modprobed-db service to scan and store new kernel modules";
        wants = [ "modprobed-db.timer" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/modprobed-db storesilent";
          ExecStop = "${cfg.package}/bin/modprobed-db storesilent";
          Type = "simple";
        };
        path = builtins.attrValues {
          inherit (pkgs) gawk getent coreutils gnugrep gnused kmod;
        };
      };
      timers.modprobed-db = {
        wantedBy = [ "timers.target" ];
        partOf = [ "modprobed-db.service" ];
        timerConfig = {
          Persistent = true;
          OnUnitActiveSec = "1h";
        };
      };
    };
  };
}
