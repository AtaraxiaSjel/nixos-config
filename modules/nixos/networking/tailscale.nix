{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.ataraxia.vpn.tailscale;
in
{
  options.ataraxia.vpn.tailscale = {
    enable = mkOption {
      type = bool;
      default = config.services.tailscale.enable;
      description = "Enable tailsacle";
    };
  };

  config = mkIf cfg.enable {
    persist.state.directories = [ "/var/lib/tailscale" ];
  };
}
