{ pkgs, lib, config, ... }: {

  environment.sessionVariables = config.home-manager.users.alukard.home.sessionVariables // rec {
    LESS = "MR";
    LESSHISTFILE = "~/.local/share/lesshist";
    SYSTEMD_LESS = LESS;
  };

  home-manager.users.alukard = {
    services.udiskie.enable = true;
    news.display = "silent";
    systemd.user.startServices = true;
  };

  home-manager.users.alukard.home.stateVersion = "21.11";
  system.stateVersion = "21.11";

  systemd.services.systemd-timesyncd.wantedBy = [ "multi-user.target" ];
  systemd.timers.systemd-timesyncd = { timerConfig.OnCalendar = "hourly"; };
}
