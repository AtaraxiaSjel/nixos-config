{
  config,
  lib,
  pkgs,
  useHomeManager,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.waydroid;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.programs.waydroid = {
    enable = mkEnableOption "Enable waydroid";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ wl-clipboard ];
    virtualisation.waydroid.enable = true;

    persist.state.directories = [ "/var/lib/waydroid" ];

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        home.packages = with pkgs; [ waydroid-script ];
        persist.state.directories = [ ".local/share/waydroid" ];
      };
    };
  };
}
