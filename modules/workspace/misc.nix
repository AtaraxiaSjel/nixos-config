{ pkgs, lib, config, ... }: {

  # programs.ssh.askPassword = "${pkgs.plasma5.ksshaskpass}/bin/ksshaskpass";
  environment.sessionVariables = {
    EDITOR = config.defaultApplications.editor.cmd;
    VISUAL = config.defaultApplications.editor.cmd;
    LESS = "-asrRix8";
    NIX_AUTO_RUN = "1";
  };

  services.atd.enable = true;

  home-manager.users.alukard = {
    xdg.enable = true;

    services.udiskie.enable = true;

    programs.git = {
      enable = true;
      package = pkgs.git-with-libsecret;
      userEmail = "alukard.develop@gmail.com";
      userName = "Dmitriy Kholkin";
      extraConfig = {
        credential = {
          helper = "libsecret";
        };
        core = {
          editor = "code --wait";
        };
      };
    };
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    news.display = "silent";

    home.keyboard = {
      options = [ "grp:win_space_toogle" ];
      layout = "us,ru";
    };

    home.file.".icons/default" = {
      source = "${pkgs.bibata-cursors}/share/icons/Bibata_Oil";
    };

    systemd.user.startServices = true;
  };
}
