{
  config,
  lib,
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

  config =
    let
      baseRole = {
        ataraxia.defaults.hardware.enable = mkDefault true;
        ataraxia.defaults.locale.enable = mkDefault true;
        ataraxia.defaults.lix.enable = mkDefault true;
        ataraxia.defaults.nix.enable = mkDefault true;
        ataraxia.defaults.ssh.enable = mkDefault true;
        ataraxia.defaults.users.enable = mkDefault true;

        persist.enable = mkDefault true;
        persist.cache.clean.enable = true;

        # Do not compress journal logs if using native fs compression
        services.journald.extraConfig = mkIf fsCompression (mkDefault "Compress=false");

        boot.initrd.systemd.enable = mkDefault true;
        services.userborn.enable = mkDefault true;
        system.rebuild.enableNg = mkDefault true;
        system.switch.enableNg = mkDefault true;
        system.etc.overlay.enable = mkDefault true;
        system.etc.overlay.mutable = mkDefault true;

        zramSwap = {
          enable = true;
          algorithm = "zstd";
          memoryPercent = 100;
        };
      };
      serverRole = recursiveUpdate baseRole {
        ataraxia.profiles.hardened = mkDefault true;
        ataraxia.profiles.minimal = mkDefault true;

        time.timeZone = "Etc/UTC";
      };
      desktopRole = recursiveUpdate baseRole {
        ataraxia.defaults.hardware.graphics = mkDefault true;
        ataraxia.defaults.sound.enable = mkDefault true;

        location = {
          provider = "manual";
          latitude = 48;
          longitude = 44;
        };
      };
    in
    mkMerge [
      (mkIf (role == "base") baseRole)
      (mkIf (role == "server") serverRole)
      (mkIf (role == "desktop") desktopRole)
    ];
}
