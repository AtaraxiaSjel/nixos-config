{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.atuin;

  homeDir = config.home.homeDirectory;
  atuin-ai-port = "11111";
in
{
  options.ataraxia.programs.atuin = {
    enable = mkEnableOption "Enable atuin program";
  };

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      daemon.enable = true;
      # forceOverwriteSettings = true;
      # flags = [ ];
      settings = {
        # auto_sync = true;
        # sync_frequency = "5m";
        # sync_address = "https://api.atuin.sh";
        search_mode = "fuzzy";
        style = "compact";
        syntax_highlight = true;
        workspaces = true;
        logs = {
          enabled = true;
          dir = "${homeDir}/.local/share/atuin/logs";
          retention = 3;
        };
        ai = {
          enable = true;
          session_continue_minutes = 15;
          endpoint = "http://localhost:${atuin-ai-port}";
          endpoint_protocol = "oss";
          opening.send_cwd = true;
          opening.send_last_command = true;
        };
      };
    };

    virtualisation.quadlet.containers.atuin-ai = {
      autoStart = true;
      serviceConfig = {
        RestartSec = "10";
        Restart = "always";
      };
      containerConfig = {
        image = "ghcr.io/atuinsh/atuin-ai-server:latest";
        addHosts = [ "host.containers.internal:host-gateway" ];
        autoUpdate = "registry";
        publishPorts = [ "127.0.0.1:${atuin-ai-port}:8080/tcp" ];
        userns = "keep-id";
        volumes = [
          "${homeDir}/.config/atuin/ai-config.toml:/etc/atuin-ai/config.toml"
        ];
      };
    };

    persist.state.directories = [
      ".config/atuin"
      ".local/share/atuin"
    ];
  };
}
