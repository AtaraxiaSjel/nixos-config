{ config, ... }: {
  home-manager.users.${config.mainuser} = {
    programs.git = {
      enable = true;
      lfs.enable = true;
      userEmail = "ataraxiadev@ataraxiadev.com";
      userName = "Dmitriy Kholkin";
      signing = {
        signByDefault = true;
        key = "922DA6E758A0FE4CFAB4E4B2FD266B810DF48DF2";
      };
      ignores = [ ".envrc" ".direnv" "*~" ".#*" "#*#" ];
      extraConfig = {
        core = {
          editor = "code --wait";
        };
        init = {
          defaultBranch = "master";
        };
        pull.rebase = true;
      };
    };
  };
}