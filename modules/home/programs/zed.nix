{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.theme) fonts;
  cfg = config.ataraxia.programs.zed-editor;

  jsonFormat = pkgs.formats.json { };
in
{
  options.ataraxia.programs.zed-editor = {
    enable = mkEnableOption "Enable zed program";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "dockerfile"
        "ini"
        "jq"
        "make"
        # "material-icon-theme"
        "nix"
        "nu"
        "qml"
        "sql"
        "strace"
        "toml"
      ];
      userSettings = {
        # Font settings
        buffer_font_fallbacks = [ ".ZedMono" ];
        buffer_font_family = fonts.mono.family;
        buffer_font_size = 15;
        buffer_font_weight = 400;
        ui_font_fallbacks = [ ".SystemUIFont" ];
        ui_font_family = fonts.sans.family;
        ui_font_features = {
          calt = false;
        };
        ui_font_size = 16;
        ui_font_weight = 400;

        auto_update = false;
        autosave = {
          after_delay = {
            milliseconds = 500;
          };
        };
        base_keymap = "VSCode";
        calls = {
          mute_on_join = true;
          share_on_join = false;
        };
        collaboration_panel = {
          button = false;
        };
        cursor_blink = true;
        disable_ai = false;
        # icon_theme = "Material Icon Theme";
        indent_guides = {
          active_line_width = 2;
          line_width = 1;
        };
        inlay_hints = {
          toggle_on_modifiers_press = {
            alt = true;
          };
        };
        journal = {
          hour_format = "hour24";
        };
        languages = {
          Nix = {
            language_servers = [
              "nixd"
              "!nil"
            ];
          };
        };
        load_direnv = "shell_hook";
        lsp = {
          nixd = {
            initialization_options = {
              formatting = {
                command = [ "nixfmt" ];
              };
            };
          };
          rust-analyzer = {
            binary = {
              path = lib.getExe pkgs.rust-analyzer;
            };
          };
          package-version-server = {
            binary.path = lib.getExe pkgs.package-version-server;
          };
        };
        middle_click_paste = false;
        minimap = {
          show = "auto";
        };
        node = {
          npm_path = lib.getExe' pkgs.nodejs "npm";
          path = lib.getExe pkgs.nodejs;
        };
        restore_on_startup = "none";
        seed_search_query_from_cursor = "selection";
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        use_smartcase_search = true;
        vim_mode = false;
      };
    };

    xdg.configFile = {
      "zed/tasks.json".source = jsonFormat.generate "zed-user-tasks" [
        {
          label = "List TODOs";
          command = "rg";
          args = [
            "--hyperlink-format=file://{path}:{line}"
            "-e TODO"
            "-e FIXME"
            "-e HACK"
          ];
          cwd = "\${ZED_WORKTREE_ROOT}";
          use_new_terminal = true;
          allow_concurrent_runs = false;
          reveal = "always";
          hide = "never";
          show_summary = false;
          show_command = false;
          reveal_target = "dock";
        }
      ];
    };

    persist.state.directories = [
      ".config/zed"
      ".local/share/zed"
    ];
  };
}
