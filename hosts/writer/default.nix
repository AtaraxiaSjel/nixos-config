{ lib, ... }:
let
  inherit (lib) mkDefault mkForce;
  # defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  imports = [

  ];

  ataraxia.defaults.role = "desktop";
  ### lightweight. rewrite desktop role ###
  # TODO: broken
  programs.nix-index.enable = mkForce false;
  programs.nix-index-database.comma.enable = mkForce false;

  ataraxia.defaults.boot.enable = false;
  ataraxia.defaults.determinate.enable = false;
  ataraxia.defaults.hardware.enable = false;
  system.etc.overlay.enable = true;
  ataraxia.defaults.hardware.graphics = false;
  ataraxia.wayland.enable = mkDefault false;
  ataraxia.wayland.hyprland.enable = mkDefault false;
}
