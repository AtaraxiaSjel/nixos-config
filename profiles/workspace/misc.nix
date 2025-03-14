{ lib, config, ... }:
with config.deviceSpecific; {

  environment.sessionVariables =
    builtins.mapAttrs (_n: v: lib.mkForce (toString v))
    config.home-manager.users.${config.mainuser}.home.sessionVariables //
    rec {
      LESS = "MR";
      LESSHISTFILE = "~/.local/share/lesshist";
      SYSTEMD_LESS = LESS;
      CARGO_HOME = "${config.home-manager.users.${config.mainuser}.xdg.dataHome}/cargo";
      LIBVIRT_DEFAULT_URI = "qemu:///system";
    };

  services.journald.extraConfig = "Compress=false";
  services.gvfs.enable = !isServer;
  services.upower.enable = lib.mkDefault isLaptop;
  xdg.portal.enable = !isServer;
  xdg.portal.config.common.default = "*";
  # xdg.portal.xdgOpenUsePortal = true;

  home-manager.users.${config.mainuser} = {
    news.display = "silent";
    systemd.user.startServices = true;

    xdg.configFile."nixpkgs/config.nix".text = ''
      { allowUnfree = true; android_sdk.accept_license = true; }
    '';
  };

  systemd.services.systemd-timesyncd.wantedBy = [ "multi-user.target" ];
  systemd.timers.systemd-timesyncd = { timerConfig.OnCalendar = "hourly"; };

  persist.state.files = lib.mkIf (devInfo.fileSystem == "zfs") [
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
  ] ++ lib.optionals config.services.mysql.enable [
    config.services.mysql.dataDir
  ] ++ lib.optionals ((devInfo.fileSystem != "zfs") && config.services.postgresql.enable) [
    "/var/lib/postgresql"
  ];
  persist.state.homeDirectories = [
    "projects"
    "nixos-config"
    ".config/sops"
  ] ++ lib.optionals (!isServer) [
    "games"
    # "persist"
  ];
}
