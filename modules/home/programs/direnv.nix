{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.direnv;
in
{
  options.ataraxia.programs.direnv = {
    enable = mkEnableOption "Enable direnv program";
  };

  config = mkIf cfg.enable {
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    persist.state.directories = [ ".local/share/direnv" ];
  };
}
