{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.ataraxia.filesystems.btrfs;
in
{
  options.ataraxia.filesystems.btrfs = {
    enable = mkEnableOption "Root on btrfs";
  };

  config = mkIf cfg.enable { };
}
