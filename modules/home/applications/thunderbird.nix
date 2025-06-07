{
  config,
  lib,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.thunderbird;
  username = config.home.username;
in
{
  options.ataraxia.programs.thunderbird = {
    enable = mkEnableOption "Enable thunderbird program";
  };

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      profiles.${username} = {
        isDefault = true;
        withExternalGnupg = true;
      };
    };

    defaultApplications.mail = {
      cmd = getExe config.programs.thunderbird.package;
      desktop = "thunderbird";
    };

    startupApplications = [
      config.defaultApplications.mail.cmd
    ];

    persist.state.directories = [
      ".thunderbird/${username}"
    ];
  };
}
