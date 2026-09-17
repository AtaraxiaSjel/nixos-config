{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.wayland.noctalia;
  homeDir = config.home.homeDirectory;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  options.ataraxia.wayland.noctalia = {
    enable = mkEnableOption "Enable noctalia";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      satty
      wl-clipboard
    ];

    # Rewrite some settings
    gtk.theme.name = "adw-gtk3";
    gtk.theme.package = pkgs.adw-gtk3;
    gtk.gtk4.theme = null;
    catppuccin.alacritty.enable = false;
    catppuccin.hyprland.enable = false;
    catppuccin.qt5ct.enable = false;
    catppuccin.kvantum.enable = false;
    ataraxia.wayland.waybar.enable = false;

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      settings = {
        config_version = 2;
        bar = {
          default = {
            capsule_group = [
              {
                enabled = true;
                fill = "surface_variant";
                id = "g1";
                members = [
                  "date"
                  "clock"
                ];
                opacity = 1.0;
                padding = 6.0;
              }
            ];
            center = [
              "group:g1"
            ];
            end = [
              "media"
              "notifications"
              "clipboard"
              "network"
              "bluetooth"
              "volume"
              "brightness"
              "battery"
              "control-center"
              "session"
              "sysmon"
              "spacer_2"
              "tray"
            ];
          };
        };
        battery = {
          device = {
            "/org/freedesktop/UPower/devices/headset_dev_B0_F0_0C_6F_36_9F" = {
              warning_threshold = 20;
            };
          };
        };
        idle = {
          behaviour_order = [
            "screen-off"
            "lock"
          ];
          behaviour.screen-off = {
            action = "screen_off";
            enabled = true;
            timeout = 600;
          };
          behaviour.lock = {
            action = "lock";
            enabled = true;
            timeout = 1800;
          };
        };
        shell = {
          font_family = config.theme.fonts.sans.family;
          screenshot = {
            copy_to_clipboard = false;
            directory = "${homeDir}/Pictures/Screenshots";
            pipe_command = "satty -f - -o \"$NOCTALIA_SCREENSHOT_PATH\" --copy-command wl-copy --early-exit";
            pipe_to_command = true;
            save_to_file = false;
          };
        };
        theme = {
          builtin = "Noctalia";
          community_palette = "Peche";
          mode = "dark";
          source = "wallpaper";
          templates = {
            builtin_ids = [
              "alacritty"
              "gtk3"
              "gtk4"
              "hyprland"
              "qt"
            ];
            community_ids = [
              "zen-browser"
              "vscode"
              "zed"
              "bat"
              "telegram"
              "zathura"
              "hyprtoolkit"
            ];
          };
          wallpaper_scheme = "m3-content";
        };
        wallpaper = {
          automation = {
            enabled = true;
            interval_seconds = 1200;
          };
          directory = "${homeDir}/Pictures/Wallpapers";
        };
        widget = {
          control-center = {
            enabled = false;
          };
          session = {
            enabled = false;
          };
          spacer_2 = {
            type = "spacer";
          };
        };
      };
    };

    persist.state.directories = [
      ".config/noctalia"
      ".local/state/noctalia"
    ];
  };
}
