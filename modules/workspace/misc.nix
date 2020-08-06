{ pkgs, lib, config, ... }: {

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
      userEmail = "alukard.develop@gmail.com";
      userName = "Dmitriy Kholkin";
      signing.key = "922DA6E758A0FE4CFAB4E4B2FD266B810DF48DF2";
      extraConfig = {
        core = {
          editor = "code --wait";
        };
      };
    };

    # GPG with SSH
    programs.gpg = {
      enable = true;
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "gnome3";
      sshKeys = [ "E6A6377C3D0827C36428A290199FDB3B91414AFE" ];
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      # enable use_flake support
      # stdlib = ''
      #   use_flake() {
      #     watch_file flake.nix
      #     watch_file flake.lock
      #     eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
      #   }
      # '';
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
