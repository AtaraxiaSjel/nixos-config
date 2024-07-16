
{ stdenvNoCC, writeShellScriptBin, libnotify, mpv, wl-clipboard, term }:
let
  yt-mpv = writeShellScriptBin "yt-mpv" ''
    if [[ "$1" != "--no-video" ]]; then
      ${libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Video" "$(${wl-clipboard}/bin/wl-paste)"
      ${mpv}/bin/mpv --fs "$(${wl-clipboard}/bin/wl-paste)"
    else
      ${libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Audio" "$(${wl-clipboard}/bin/wl-paste)"
      ${term} -e ${mpv}/bin/mpv --no-video "$(${wl-clipboard}/bin/wl-paste)"
    fi
  '';
in
stdenvNoCC.mkDerivation {
  name = "youtube-to-mpv";
  src = yt-mpv;
  installPhase = ''
    mkdir -p $out/bin
    mv ./bin/yt-mpv $out/bin/yt-mpv
  '';
}