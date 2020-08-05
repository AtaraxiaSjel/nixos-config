{ pkgs, lib, config, ... }: {

  # programs.ssh.askPassword = "${pkgs.plasma5.ksshaskpass}/bin/ksshaskpass";
  environment.sessionVariables = {
    EDITOR = config.defaultApplications.editor.cmd;
    VISUAL = config.defaultApplications.editor.cmd;
    LESS = "-asrRix8";
    NIX_AUTO_RUN = "1";
  };

  # GPG with SSH
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
  '';

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

    # GPG with SSH
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gtk2";
      sshKeys = [ "2356C0BF89D7EF7B322FA06C54A95E8E018FEBD2" ];
    };
    programs.gpg.enable = true;
    home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
    # --END--

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
