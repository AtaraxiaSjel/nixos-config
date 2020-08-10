
{ stdenv, pkgs, term }:
# TODO: config.defaultApplications doesn't work
let
  yt-mpv = pkgs.writeShellScriptBin "yt-mpv" ''
      if [[ "$1" != "--no-video" ]]; then
        ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Video" "$(xclip -o)"
        ${pkgs.mpv}/bin/mpv --fs "$(xclip -o)"
      else
        ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Audio" "$(xclip -o)"
        ${term} -e ${pkgs.mpv}/bin/mpv --no-video "$(xclip -o)"
      fi
    '';
in
stdenv.mkDerivation rec {
  name = "youtube-to-mpv";
  src = yt-mpv;
  installPhase = ''
    mkdir -p $out/bin
    mv ./bin/yt-mpv $out/bin/yt-mpv
  '';
}