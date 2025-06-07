{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.ataraxia.services.modprobed-db;
in
{
  options = {
    ataraxia.services.modprobed-db = {
      enable = mkEnableOption "modprobed-db service to scan and store new kernel modules";
      package = mkPackageOption pkgs "modprobed-db" { };
    };
  };

  config = mkIf cfg.enable {
    systemd.user = {
      services.modprobed-db = {
        Unit = {
          Description = "modprobed-db service to scan and store new kernel modules";
          Wants = [ "modprobed-db.timer" ];
        };
        Service = {
          ExecStart = "${cfg.package}/bin/modprobed-db storesilent";
          Type = "simple";
        };
        Install.WantedBy = [ "default.target" ];
      };
      timers.modprobed-db = {
        Unit.PartOf = [ "modprobed-db.service" ];
        Timer = {
          Persistent = true;
          OnUnitActiveSec = "1h";
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };

    persist.state.directories = [
      ".config/modprobed-db"
    ];
  };
}
