{ config, pkgs, lib, ... }: {
  # TODO: settings?
  home-manager.users.${config.mainuser} = {
    programs = {
      bat = {
        enable = true;
        # config = {};
        extraPackages = with pkgs.bat-extras; [
          # batdiff
          batgrep
          batman
          batwatch
        ];
        # syntaxes = {};
        # themes = {};
      };
      bottom.enable = true;
      fzf.enable = true;
      fzf.enableZshIntegration = true;
      gitui = {
        enable = true;
        # keyConfig = '''';
      };
      micro = {
        enable = true;
        # settings = {};
      };
      zathura = {
        enable = true;
        extraConfig = ''
          set selection-clipboard clipboard
        '';
        # mappings = {};
        # options = {};
      };
      zsh.syntaxHighlighting.enable = true;
    };
  };

  defaultApplications = {
    pdf = let
      home = config.home-manager.users.${config.mainuser};
      zathura-pkg = home.programs.zathura.package;
    in {
      cmd = lib.getExe zathura-pkg;
      desktop = "zathura";
    };
  };
}
