{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.run0;
in
{
  options.ataraxia.defaults.run0 = {
    enable = mkEnableOption "Use run0 by default";
  };

  config = mkIf cfg.enable {
    security.sudo.enable = false;
    security.run0.enableSudoAlias = true;
    # TODO: remove polkit, enable persistentAuth after 26.11 update
    # security.run0.persistentAuth.enable = true;
    # security.run0.persistentAuth.enableRemote = true;
    # system.tools.nixos-rebuild.enableRun0Elevation = true;
    environment.systemPackages = [ pkgs.polkit-stdin-agent ];
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" && subject.active) {
          return polkit.Result.AUTH_ADMIN_KEEP;
        }
      });
    '';
  };
}
