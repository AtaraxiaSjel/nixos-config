{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.element-desktop;

  wrapper = pkgs.writeShellApplication {
    name = "element-desktop";
    runtimeInputs = [ pkgs.element-desktop ];
    text = ''
      ${getExe pkgs.element-desktop} --password-store="gnome-libsecret"
    '';
  };
in
{
  options.ataraxia.programs.element-desktop = {
    enable = mkEnableOption "Enable Element Desktop program";
  };

  config = mkIf cfg.enable {
    home.packages = [ wrapper ];
    persist.state.directories = [ ".config/Element" ];
  };
}
