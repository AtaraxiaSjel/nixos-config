# Custom packages overlay.
#
# Auto-discovers every package under ../pkgs/by-name/<pname>/package.nix
# via callPackage, so adding a package needs no overlay edits.
# Signature keeps `inputs` for packages that need flake inputs later:
#   foo = final.callPackage ../pkgs/by-name/foo/package.nix {
#     inherit (inputs) some-input;
#   };
_inputs: final: prev:
let
  fromDirectory =
    prev.lib.packagesFromDirectoryRecursive or prev.lib.filesystem.packagesFromDirectoryRecursive;
in
fromDirectory {
  callPackage = final.callPackage;
  directory = ../pkgs/by-name;
}
