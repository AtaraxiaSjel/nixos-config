
{ stdenv, pkgs }:
let
  myScript = if config.deviceSpecific.isLaptop then
    pkgs.writeShellScriptBin "yt-mpv" ''
      BATTERY="`${pkgs.acpi}/bin/acpi -b | grep --invert-match unavailable | head -1`"
      STATUS=`awk -F'[,:] ' '{print $2}' <<< "$BATTERY"`
      ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Video" "$(xclip -o)";
      if [[ "$STATUS" == "Discharging" ]]; then
        ${pkgs.mpv}/bin/mpv --hwdec=vaapi --fs --ytdl-format="bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best" "$(xclip -o)"
      else
        ${pkgs.mpv}/bin/mpv --hwdec=vaapi --fs "$(xclip -o)"
      fi
    ''
  else
    pkgs.writeShellScriptBin "yt-mpv" ''
      ${pkgs.libnotify}/bin/notify-send -t 3000 --icon=video-television "Playing Video" "$(xclip -o)";
      ${pkgs.mpv}/bin/mpv --hwdec=vaapi --fs "$(xclip -o)"
    '';
in
stdenv.mkDerivation rec {
  name = "youtube-to-mpv";
  src = myScript;
  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/yt-mpv $out/bin/yt-mpv
  '';
}