{ config, pkgs, ... }:
{
  home-manager.users.${config.mainuser} = {
    programs.mpv = {
      enable = true;
      config = {
        vo = "gpu";
        gpu-context = "wayland";
        save-position-on-quit = "yes";
        hwdec = if config.deviceSpecific.devInfo.gpu.vendor == "nvidia" then
          "vdpau"
        else
          "vaapi";
        ytdl-format = if config.deviceSpecific.isLaptop then
          "bestvideo[height<=?1080]+bestaudio/best"
        else
          "bestvideo[height<=?2160]+bestaudio/best";
      };
    };
    home.file.".config/yt-dlp/config".text = ''
      --cookies-from-browser "firefox:$HOME/.mozilla/firefox/${config.mainuser}"
      --mark-watched
    '';
  };

  defaultApplications.media-player = {
    cmd = "${pkgs.mpv}/bin/mpv";
    desktop = "mpv";
  };

  persist.state.homeDirectories = [
    ".config/mpv"
  ];
}