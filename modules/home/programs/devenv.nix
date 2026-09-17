{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  cfg = config.ataraxia.programs.devenv;

  package = pkgs.devenv;
in
{
  options.ataraxia.programs.devenv = {
    enable = mkEnableOption "Enable devenv program";
  };

  config = mkIf cfg.enable {
    # TODO: add after nixos 26.11 update
    # programs.devenv.enable = true;

    home.packages = [ package ];

    programs.zsh.initContent = ''
      eval "$(${getExe package} hook zsh)"
    '';

    programs.nushell.extraConfig = "source ${
      pkgs.runCommand "devenv-nushell-config.nu" { } ''
        ${getExe package} hook nu > $out
      ''
    } ";
  };
}
