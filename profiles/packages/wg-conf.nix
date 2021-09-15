{ stdenv, pkgs }:
let
  myScript = pkgs.writeShellScriptBin "wg-conf" ''
    if [[ -z "$1" ]]; then
      exit 1
    fi
    systemctl stop wg-quick-wg0.service
    cp "$1" /root/wg0.conf
    systemctl start wg-quick-wg0.service
  '';
in
stdenv.mkDerivation rec {
  name = "wg-conf";
  src = myScript;
  installPhase = ''
    mkdir -p $out/bin
    mv ./bin/wg-conf $out/bin/wg-conf
  '';
}