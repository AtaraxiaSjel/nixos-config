{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    ;
  inherit (lib.types) nullOr path str;
  cfg = config.ataraxia.security.password-store;
in
{
  options.ataraxia.security.password-store = {
    enable = mkEnableOption "Whether to enable password store";
    autoSync = mkEnableOption "Whether to enable automatic sync of password store";
    store = mkOption {
      type = path;
      default = "${config.xdg.dataHome}/password-store";
    };
    gnupgHome = mkOption {
      type = path;
      default =
        if config.programs.gpg.enable then config.programs.gpg.homedir else "${config.xdg.dataHome}/gnupg";
    };
    repo = mkOption {
      default = null;
      description = "Git repository to sync with";
      type = nullOr str;
    };
    sshKey = mkOption {
      default = null;
      description = "Ssh key to use for private repository";
      type = nullOr str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.autoSync && cfg.repo == null);
        message = "If autoSync enabled, you must set repo to sync";
      }
      {
        assertion = !(cfg.autoSync && cfg.sskKey == null);
        message = "If autoSync enabled, you must set sshKey for connection to repo";
      }
    ];

    # TODO: autosync with git

    programs.password-store = {
      enable = true;
      package =
        if config.ataraxia.wayland.enable then
          pkgs.pass.withExtensions (exts: [ exts.pass-otp ])
        else
          pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
      settings.PASSWORD_STORE_DIR = cfg.store;
    };

    persist.state.directories = [ cfg.store ];
  };
}
