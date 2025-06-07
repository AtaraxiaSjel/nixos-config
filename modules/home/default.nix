{ lib, ... }:
let
  inherit (builtins)
    attrValues
    concatLists
    mapAttrs
    readDir
    ;
  inherit (lib) hasSuffix mkOption remove;
  inherit (lib.types)
    attrsOf
    listOf
    path
    str
    submodule
    ;

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

  options = {
    defaultApplications = mkOption {
      default = { };
      type = attrsOf (
        submodule (
          { ... }:
          {
            options = {
              cmd = mkOption { type = path; };
              desktop = mkOption { type = str; };
            };
          }
        )
      );
      description = "Preferred applications";
    };

    startupApplications = mkOption {
      type = listOf str;
      description = "Applications to run on startup";
    };
  };
}
