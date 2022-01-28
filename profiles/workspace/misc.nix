{ pkgs, lib, config, ... }: {

  environment.sessionVariables = config.home-manager.users.alukard.home.sessionVariables // rec {
    LESS = "MR";
    LESSHISTFILE = "~/.local/share/lesshist";
    SYSTEMD_LESS = LESS;
    CARGO_HOME = "${config.home-manager.users.alukard.xdg.dataHome}/cargo";
  };

  home-manager.users.alukard = {
    news.display = "silent";
    systemd.user.startServices = true;
    home.stateVersion = "21.11";

    #TODO: Move to another file
    services.pass-secret-service.enable = true;
    systemd.user.services.pass-secret-service = {
      Service = {
        ExecStart = lib.mkForce
          "${pkgs.pass-secret-service}/bin/pass_secret_service --path ${config.environment.variables.PASSWORD_STORE_DIR}";
        Type = "dbus";
        BusName = "org.freedesktop.secrets";
      };
      Unit = rec {
        Wants = [ "gpg-agent.service" "activate-secrets.service" ];
        After = Wants;
        PartOf = [ "graphical-session-pre.target" ];
      };
    };
  };

  system.stateVersion = "21.11";

  systemd.services.systemd-timesyncd.wantedBy = [ "multi-user.target" ];
  systemd.timers.systemd-timesyncd = { timerConfig.OnCalendar = "hourly"; };
}
