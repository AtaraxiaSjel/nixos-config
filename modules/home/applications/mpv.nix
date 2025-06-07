{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.mpv;

  gpu = if (osConfig != null) then osConfig.ataraxia.defaults.hardware.gpuVendor else null;
in
{
  options.ataraxia.programs.mpv = {
    enable = mkEnableOption "Enable mpv program";
  };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      config = {
        vo = "gpu-next";
        gpu-context = "wayland";
        save-position-on-quit = "yes";
        hwdec = if gpu == "nvidia" then "vdpau" else "vaapi";
      };
    };

    defaultApplications.media-player = {
      cmd = "${config.programs.mpv.package}/bin/mpv";
      desktop = "mpv";
    };

    persist.state.directories = [
      ".config/mpv"
    ];
  };

}
