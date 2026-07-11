{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.emulators;
in
{
  options.ataraxia.programs.emulators = {
    enable = mkEnableOption "Enable various console emulators";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      azahar
      cemu
      eden
    ];

    persist.state.directories = [
      ".config/azahar-emu"
      ".config/Cemu"
      ".config/eden"
      ".local/share/azahar-emu"
      ".local/share/Cemu"
      ".local/share/eden"
    ];
  };
}
