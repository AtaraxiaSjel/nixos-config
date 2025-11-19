{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/perlless.nix")
  ];

  ataraxia.profiles.minimal = true;
  system.forbiddenDependenciesRegexes = lib.mkForce [ ];

  boot.initrd.systemd.enable = false;
  # Requires initrd-systemd
  system.etc.overlay.enable = false;
  system.etc.overlay.mutable = false;

  documentation.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;
  security.apparmor.enable = false;
  services.logrotate.enable = lib.mkForce false;
  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;
  system.installer.channel.enable = false;
  programs.vim.enable = false;
  programs.vim.defaultEditor = false;

  # Do not pin source. Aggresive image size optimization.
  nixpkgs.flake.source = lib.mkForce null;
  nix.registry.nixpkgs.flake = lib.mkForce null;
  nix.registry.nixpkgs.to = lib.mkForce {
    owner = "NixOS";
    repo = "nixpkgs/nixpkgs-unstable";
    type = "github";
  };
  # For even more reduction of size we can recompile systemdMinimal
  # with some necessary modules enabled
  # systemd.package = pkgs.systemdMinimal.override {
  #   withNetworkd = true;
  #   # ...etc
  # };
  # TODO: investigate procps
}
