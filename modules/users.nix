{ config, lib, pkgs, ... }:
with lib;
with types; {
  options = {
    mainuser = mkOption { type = str; };
  };
}