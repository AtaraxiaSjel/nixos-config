{ lib, ... }:
let
  inherit (builtins)
    attrValues
    concatLists
    mapAttrs
    readDir
    ;
  inherit (lib) hasSuffix remove;

  filterRoot = remove (./. + "/default.nix");

  findModules =
    dir:
    concatLists (
      attrValues (
        mapAttrs (
          name: type:
          if type == "directory" then
            if (readDir (dir + "/${name}")) ? "default.nix" then
              [
                (dir + "/${name}")
              ]
            else
              findModules (dir + "/${name}")
          else if (type == "regular" && (hasSuffix ".nix" name)) then
            [
              (dir + "/${name}")
            ]
          else
            [ ]
        ) (readDir dir)
      )
    );
in
{
  imports = filterRoot (findModules ./.);
}
