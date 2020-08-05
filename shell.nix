{ pkgs ? import <nixpkgs> { } }:
let
  rebuild = pkgs.writeShellScriptBin "rebuild" ''
    if [[ -z $1 ]]; then
      echo "Usage: $(basename $0) {switch|boot|test}"
    else
      sudo nixos-rebuild $1 --flake .
    fi
  '';
in
pkgs.mkShell {
  name = "nixflk";
  nativeBuildInputs = with pkgs; [
    git
    git-crypt
    rebuild
  ];
}
