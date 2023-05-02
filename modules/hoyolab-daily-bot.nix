{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.hoyolab-daily-bot;
in {
  options.services.hoyolab-daily-bot = {
    enable = mkEnableOption "Hoyolab Daily Bot";

    package = mkOption {
      type = types.package;
      description = lib.mdDoc "Which package to use.";
      default = pkgs.hoyolab-daily-bot;
      defaultText = literalExpression "pkgs.hoyolab-daily-bot";
    };

    cookieFiles = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description =
        lib.mdDoc "List of paths to cookie files. If not provided, use cookie from browser.";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = lib.mdDoc "";
    };

    startAt = mkOption {
      type = types.str;
      default = "*-*-* 20:00:00";
      description = lib.mdDoc "";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.hoyolab-daily-bot = {
      description = "Hoyolab Daily Login Bot.";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        StateDirectory = "hoyolab-daily-bot";
      };
      startAt = cfg.startAt;
      script = if (cfg.cookieFiles == [ ]) then ''
        ${cfg.package}/bin/hoyolab-daily-bot
      '' else ''
        ${concatMapStringsSep "\n" (x:
          "${cfg.package}/bin/hoyolab-daily-bot -c ${x}"
        ) cfg.cookieFiles}
      '';
    };
  };
}