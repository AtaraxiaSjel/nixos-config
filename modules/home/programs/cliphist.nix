{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.cliphist;
in
{
  options.ataraxia.programs.cliphist = {
    enable = mkEnableOption "Enable cliphist program";
  };

  config = mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      allowImages = true;
      extraOptions = [
        "-max-dedupe-search"
        "20"
        "-max-items"
        "200"
      ];
      systemdTargets = [ "graphical-session.target" ];
    };

    # TODO: fix persist module recursive directories
    # persist.state.directories = [
    #   ".cache/cliphist"
    # ];
  };
}
