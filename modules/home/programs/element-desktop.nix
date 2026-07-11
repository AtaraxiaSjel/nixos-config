{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.element-desktop;

  wrapper = (
    pkgs.symlinkJoin {
      name = "element-desktop";
      paths = [ pkgs.element-desktop ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/element-desktop \
          --add-flags "--password-store=\"gnome-libsecret\""
      '';
    }
  );
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
