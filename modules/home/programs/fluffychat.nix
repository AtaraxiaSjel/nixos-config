{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.fluffychat;
in
{
  options.ataraxia.programs.fluffychat = {
    enable = mkEnableOption "Enable fluffychat program";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.fluffychat ];
    persist.state.directories = [ ".local/share/chat.fluffy.fluffychat" ];
  };
}
