{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.geary;
in
{
  options.ataraxia.programs.geary = {
    enable = mkEnableOption "Enable geary program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ geary ];

    defaultApplications.mail = {
      cmd = "${pkgs.geary}/bin/geary";
      desktop = "geary";
    };

    startupApplications = [
      config.defaultApplications.mail.cmd
    ];

    persist.state.directories = [
      ".config/geary"
      ".local/share/geary"
    ];
  };
}
