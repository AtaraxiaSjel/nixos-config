{ pkgs, lib, config, ... }: {

  environment.sessionVariables =
    builtins.mapAttrs (_: toString)
    config.home-manager.users.${config.mainuser}.home.sessionVariables // rec {
      LESS = "MR";
      LESSHISTFILE = "~/.local/share/lesshist";
      SYSTEMD_LESS = LESS;
      CARGO_HOME = "${config.home-manager.users.${config.mainuser}.xdg.dataHome}/cargo";
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };

  programs.ydotool.enable = true;
  services.journald.extraConfig = "Compress=false";

  home-manager.users.${config.mainuser} = {
    news.display = "silent";
    systemd.user.startServices = true;
    nixpkgs.config.allowUnfree = true;
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
  ] ++ lib.optionals config.services.mysql.enable [
    config.services.mysql.dataDir
  ];
  persist.state.homeDirectories = [
    "projects"
    "nixos-config"
  ] ++ lib.optionals (!config.deviceSpecific.isServer) [
    "games"
    # "persist"
  ];
}
