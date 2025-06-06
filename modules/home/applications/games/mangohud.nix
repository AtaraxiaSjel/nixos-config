{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.mangohud;
in
{
  options.ataraxia.programs.mangohud = {
    enable = mkEnableOption "Enable mangohud program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ mangohud ];
    xdg.configFile."MangoHud/MangoHud.conf".text = ''
      fps_limit=60
      toggle_fps_limit=F1
      legacy_layout=false
      gpu_stats
      gpu_temp
      gpu_text=GPU
      cpu_stats
      cpu_temp
      cpu_color=2e97cb
      cpu_text=CPU
      io_color=a491d3
      vram
      vram_color=ad64c1
      ram
      ram_color=c26693
      fps
      engine_version
      engine_color=eb5b5b
      gpu_color=2e9762
      wine
      wine_color=eb5b5b
      frame_timing=1
      frametime_color=00ff00
      resolution
      vkbasalt
      media_player_color=ffffff
      time
      background_alpha=0.4
      font_size=24
      background_color=020202
      position=top-left
      text_color=ffffff
      toggle_hud=Shift_R+F12
      toggle_logging=Shift_L+F2
      output_folder=${config.home.homeDirectory}
      media_player_name=spotify
    '';
  };
}
