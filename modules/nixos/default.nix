{ lib, ... }:
let
  inherit (lib) filterAttrs;
  inherit (builtins) attrNames readDir;
  moduleDirs =
    dir:
    map (name: dir + "/${name}") (attrNames (filterAttrs (_: type: type == "directory") (readDir dir)));
in
{
  imports = moduleDirs ./.;
}
