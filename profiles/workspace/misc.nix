{ pkgs, lib, config, ... }: {

  environment.sessionVariables = rec {
    LESS = "MR";
    LESSHISTFILE = "~/.local/share/lesshist";
    SYSTEMD_LESS = LESS;
    CARGO_HOME = "${config.home-manager.users.${config.mainuser}.xdg.dataHome}/cargo";
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };

  environment.systemPackages = [ pkgs.pass-secret-service ];
  services.dbus.packages = [ pkgs.pass-secret-service ];
  xdg.portal.extraPortals = [ pkgs.pass-secret-service ];

  home-manager.users.${config.mainuser} = {
    news.display = "silent";
    systemd.user.startServices = true;

    nixpkgs.config.allowUnfree = true;

    #TODO: Move to another file
    services.pass-secret-service.enable = true;
    systemd.user.services.pass-secret-service = {
      Service = {
        Type = "dbus";
        Environment = [ "GPG_TTY=/dev/tty1" "DISPLAY=:0" ];
        BusName = "org.freedesktop.secrets";
      };
      Unit = rec {
        Wants = [ "gpg-agent.service" ];
        After = Wants;
        PartOf = [ "graphical-session-pre.target" ];
      };
    };
  };

  systemd.services.systemd-timesyncd.wantedBy = [ "multi-user.target" ];
  systemd.timers.systemd-timesyncd = { timerConfig.OnCalendar = "hourly"; };

  persist.state.files = lib.mkIf (config.deviceSpecific.devInfo.fileSystem == "zfs") [
    "/etc/zfs/zpool.cache"
  ];
  persist.cache.homeDirectories = [
    ".cache"
    ".local/share/cargo"
  ];
  persist.cache.directories = [
    "/var/cache"
  ];
  persist.state.directories = [
    "/var/lib/nixos"
    "/var/lib/systemd"
  ] ++ lib.optionals config.services.postgresql.enable [
    config.services.postgresql.dataDir
  ];
  persist.state.homeDirectories = [
    "projects"
    {
      directory = "nixos-config";
      method = "symlink";
    }
  ] ++ lib.optionals (!config.deviceSpecific.isServer) [
    "games"
    # "persist"
  ];
}
