{ stdenv, pkgs }:
let
  xonar-fp = pkgs.writeShellScriptBin "xonar-fp" ''
    CURRENT_STATE=`amixer -c 0 sget "Front Panel" | egrep -o '\[o.+\]'`
    if [[ $CURRENT_STATE == '[on]' ]]; then
        amixer -c 0 sset "Front Panel" mute
    else
        amixer -c 0 sset "Front Panel" unmute
    fi
  '';
in
stdenv.mkDerivation rec {
  name = "xonar-fp";
  src = xonar-fp;
  installPhase = ''
    mkdir -p $out/bin
    mv ./bin/xonar-fp $out/bin/xonar-fp
  '';
}