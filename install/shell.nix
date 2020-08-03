{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  name = "nixflk";
  nativeBuildInputs = with pkgs; [
    git
  ];

  shellHook = ''
    
  '';
}