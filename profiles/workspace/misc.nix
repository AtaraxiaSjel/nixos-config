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
  };

  system.stateVersion = "21.11";

  systemd.services.systemd-timesyncd.wantedBy = [ "multi-user.target" ];
  systemd.timers.systemd-timesyncd = { timerConfig.OnCalendar = "hourly"; };
}
