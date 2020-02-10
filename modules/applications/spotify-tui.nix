{ config, lib, pkgs, ...}:
let
    naersk = pkgs.callPackage pkgs.imports.naersk {};
in naersk.buildPackage {
  name = "spotify-tui";
  src = pkgs.imports.spotify-tui;
};