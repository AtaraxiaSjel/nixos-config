{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.git;
in
{
  options.ataraxia.defaults.git = {
    enable = mkEnableOption "Default git settings";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      difftastic
      gh
    ];

    programs.git = {
      enable = true;
      lfs.enable = true;
      userEmail = "ataraxiadev@ataraxiadev.com";
      userName = "Dmitriy Kholkin";
      signing = {
        signByDefault = true;
        key = "922DA6E758A0FE4CFAB4E4B2FD266B810DF48DF2";
      };
      ignores = [
        ".direnv"
        "*~"
        ".#*"
        "#*#"
      ];
      extraConfig = {
        core = {
          editor = "code --wait";
        };
        init = {
          defaultBranch = "dev";
        };
        pull.rebase = true;
        safe.directory = "*";
      };
      difftastic = {
        enable = true;
        background = "dark";
        color = "always";
        # display = "inline";
      };
    };

    persist.state.directories = [ ".config/gh" ];
  };
}
