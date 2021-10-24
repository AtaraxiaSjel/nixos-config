
{ stdenv, pkgs, term }:
let
  yt-mpv = pkgs.writeShellScriptBin "yt-mpv" ''
      if [[ "$1" != "--no-video" ]]; then
        ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Video" "$(${pkgs.xclip}/bin/xclip -o)"
        ${pkgs.mpv}/bin/mpv --fs "$(${pkgs.xclip}/bin/xclip -o)"
      else
        ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Audio" "$(${pkgs.xclip}/bin/xclip -o)"
        ${term} -e ${pkgs.mpv}/bin/mpv --no-video "$(${pkgs.xclip}/bin/xclip -o)"
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