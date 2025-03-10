{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.ataraxia.filesystems.zfs;
in
{
  options.ataraxia.filesystems.zfs = {
    enable = mkEnableOption "Root on zfs";
  };

  config = mkIf cfg.enable {
    persist.state.files = [
      "/etc/zfs/zpool.cache"
    ];
  };
}
