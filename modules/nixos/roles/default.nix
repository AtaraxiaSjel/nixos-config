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
        ataraxia.defaults.lix.enable = mkDefault true;
        ataraxia.defaults.nix.enable = mkDefault true;

        persist.enable = mkDefault true;

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
        time.timeZone = "Etc/UTC";
      };
      desktopRole = recursiveUpdate baseRole {
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
