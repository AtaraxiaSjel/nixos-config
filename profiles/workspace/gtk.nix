{ pkgs, config, lib, ... }:

{
  gtk.iconCache.enable = true;
  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ dconf gcr ];

  persist.state.homeDirectories = [ ".config/dconf" ];
}
