{ config, lib, pkgs, ... }:
with lib; {
  options = {
    services.xray = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run xray server.
          Either <literal>settingsFile</literal> or <literal>config</literal> must be specified.
        '';
      };
      package = mkOption {
        type = types.package;
        default = pkgs.xray;
        defaultText = literalExpression "pkgs.xray";
        description = ''
          Which xray package to use.
        '';
      };
      settingsFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/etc/xray/config.json";
        description = ''
          The absolute path to the configuration file.
          Either <literal>settingsFile</literal> or <literal>config</literal> must be specified.
        '';
      };
      config = mkOption {
        type = types.nullOr (types.attrsOf types.unspecified);
        default = null;
        example = {
          inbounds = [{
            port = 1080;
            listen = "127.0.0.1";
            protocol = "http";
          }];
          outbounds = [{
            protocol = "freedom";
          }];
        };
        description = ''
          The configuration object.
          Either `settingsFile` or `config` must be specified.
        '';
      };
    };
  };

  config = let
    cfg = config.services.xray;
    settingsFile = if cfg.settingsFile != null
      then cfg.settingsFile
      else pkgs.writeTextFile {
        name = "xray.json";
        text = builtins.toJSON cfg.config;
        checkPhase = ''
          ${cfg.package}/bin/xray run -test -format=json -config $out
        '';
      };
  in mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.settingsFile == null) != (cfg.config == null);
        message = "Either but not both `settingsFile` and `config` should be specified for xray.";
      }
    ];
    systemd.services.xray = {
      description = "Xray Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/xray run -format=json -config ${settingsFile}";
      };
    };
  };
}