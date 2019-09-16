{ config, lib, pkgs, ... }: {
  home-manager.users.alukard.programs.mpv = {
    enable = true;
  };

  home-manager.users.alukard.home.file.".local/share/applications/viewtube.desktop" = {
    text = ''
      [Desktop Entry]
      Name=ViewTube Protocol
      Exec=/home/alukard/.scripts/viewtube.sh %u
      Type=Application
      Terminal=false
      MimeType=x-scheme-handler/viewtube
    '';
  };
  home-manager.users.alukard.home.file.".scripts/viewtube.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      s="$(echo "$1" | sed -e "s/viewtube://")"
      v="$(echo "$s" | awk -F 'SEPARATOR' '{print $1}')"
      a="$(echo "$s" | awk -F 'SEPARATOR' '{print $2}')"
      if [ "$a" = "" ]; then
        mpv --hwdec=vaapi --osc --fs --ytdl=yes "$v"
        #cvlc -f "$v"
      else
        mpv --hwdec=vaapi --osc --fs --ytdl=yes --audio-file "$a" "$v"
        #cvlc -f --input-slave "$a" "$v"
      fi
    '';
  };
}