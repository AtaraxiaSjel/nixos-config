
{ stdenv, pkgs, isLaptop ? false }:
# TODO: отвязать от urxvt
let
  # myScript = if isLaptop then
  #   pkgs.writeShellScriptBin "yt-mpv" ''
  #     if [[ "$1" != "--no-video" ]]; then
  #       BATTERY="`${pkgs.acpi}/bin/acpi -b | grep --invert-match unavailable | head -1`"
  #       STATUS=`awk -F'[,:] ' '{print $2}' <<< "$BATTERY"`
  #       ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Video" "$(xclip -o)"
  #       if [[ "$STATUS" == "Discharging" ]]; then
  #         ${pkgs.mpv}/bin/mpv --fs --ytdl-format="bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best" "$(xclip -o)"
  #       else
  #         ${pkgs.mpv}/bin/mpv --fs "$(xclip -o)"
  #       fi
  #     else
  #       ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Audio" "$(xclip -o)"
  #       ${pkgs.rxvt_unicode}/bin/urxvt -e ${pkgs.mpv}/bin/mpv --no-video "$(xclip -o)"
  #     fi
  #   ''
  # else
  myScript = pkgs.writeShellScriptBin "yt-mpv" ''
      if [[ "$1" != "--no-video" ]]; then
        ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Video" "$(xclip -o)"
        ${pkgs.mpv}/bin/mpv --fs "$(xclip -o)"
      else
        ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Audio" "$(xclip -o)"
        ${pkgs.rxvt_unicode}/bin/urxvt -e ${pkgs.mpv}/bin/mpv --no-video "$(xclip -o)"
      fi
    '';
in
stdenv.mkDerivation rec {
  name = "youtube-to-mpv";
  src = myScript;
  installPhase = ''
    mkdir -p $out/bin
    mv ./bin/yt-mpv $out/bin/yt-mpv
  '';
}