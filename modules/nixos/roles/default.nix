{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    recursiveUpdate
    types
    ;

  defaultUser = config.ataraxia.defaults.users.defaultUser;
  fs = config.ataraxia.filesystems;
  fsCompression = fs.zfs.enable || fs.btrfs.enable;
  role = config.ataraxia.defaults.role;
in
{
  options.ataraxia.defaults = {
    role = mkOption {
      type = types.enum [
        "none"
        "base"
        "server"
        "desktop"
      ];
      default = "none";
    };
  };

  imports = [ inputs.nix-index-database.nixosModules.nix-index ];

  config =
    let
      baseRole = {
        ataraxia.defaults.boot.enable = mkDefault true;
        ataraxia.defaults.hardware.enable = mkDefault true;
        ataraxia.defaults.locale.enable = mkDefault true;
        ataraxia.defaults.lix.enable = mkDefault true;
        ataraxia.defaults.nix.enable = mkDefault true;
        ataraxia.defaults.ssh.enable = mkDefault true;
        ataraxia.defaults.users.enable = mkDefault true;

        programs.nix-index.enable = mkDefault true;
        programs.nix-index-database.comma.enable = mkDefault true;

        persist.enable = mkDefault true;
        persist.cache.clean.enable = mkDefault true;

        # Do not compress journal logs if using native fs compression
        services.journald.extraConfig = mkIf fsCompression (mkDefault "Compress=false");
        services.speechd.enable = false;

        boot.initrd.systemd.enable = mkDefault true;
        services.userborn.enable = mkDefault true;
        system.rebuild.enableNg = mkDefault true;
        system.switch.enableNg = mkDefault true;
        system.etc.overlay.enable = mkDefault true;
        system.etc.overlay.mutable = mkDefault true;

        systemd.services.systemd-timesyncd.wantedBy = [
          "multi-user.target"
        ];
        systemd.timers.systemd-timesyncd = {
          timerConfig.OnCalendar = "hourly";
        };

        environment.systemPackages = with pkgs; [
          git
        ];

        zramSwap = {
          enable = true;
          algorithm = "zstd";
          priority = mkDefault 100;
          memoryPercent = mkDefault 50;
        };
      };
      serverRole = recursiveUpdate baseRole {
        ataraxia.profiles.hardened = mkDefault true;
        ataraxia.profiles.minimal = mkDefault true;

        time.timeZone = "Etc/UTC";
        zramSwap.memoryPercent = 100;
      };
      desktopRole = recursiveUpdate baseRole {
        ataraxia.defaults.hardware.graphics = mkDefault true;
        ataraxia.defaults.sound.enable = mkDefault true;

        services.getty.autologinUser = mkDefault defaultUser;

        location = {
          provider = "manual";
          latitude = 48;
          longitude = 44;
        };

        zramSwap.memoryPercent = 150;
      };
    in
    mkMerge [
      (mkIf (role == "base") baseRole)
      (mkIf (role == "server") serverRole)
      (mkIf (role == "desktop") desktopRole)
    ];
}
