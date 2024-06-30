{ config, lib, pkgs, inputs, ... }:
let
  gpu = config.deviceSpecific.devInfo.gpu.vendor;
  ollama-port = toString config.services.ollama.port;
  searx-port = toString config.services.searx.settings.server.port;
in {
  sops.secrets.searx-env.sopsFile = inputs.self.secretsDir + /searx.yaml;

  services.ollama = {
    enable = true;
    host = "127.0.0.1";
    port = 11434;
    sandbox = false;
    openFirewall = false;
    acceleration =
      if gpu == "amd" then
        "rocm"
      else if gpu == "nvidia" then
        "cuda"
      else false;
    rocmOverrideGfx = lib.mkIf (gpu == "amd") "10.3.0";
    environmentVariables = {
      # OLLAMA_KEEP_ALIVE = "-1";
    };
  };
  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    openFirewall = false;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${ollama-port}";
      # Disable authentication
      WEBUI_AUTH = "False";
      ENABLE_SIGNUP = "False";
      WEBUI_URL = "http://localhost:8080";
      # Search
      ENABLE_RAG_WEB_SEARCH = "True";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      SEARXNG_QUERY_URL = "http://127.0.0.1:${searx-port}/search?q=<query>";

    };
  };
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    runInUwsgi = false;
    settings = {
      general.enable_metrics = false;
      search = {
        safe_search = 0;
        formats = [ "html" "csv" "json" "rss" ];
      };
      server = {
        port = 8081;
        bind_address = "127.0.0.1";
        public_instance = false;
        limiter = false;
        http_protocol_version = "1.1";
        secret_key = "@SEARX_SECRET_KEY@";
      };
      ui = {
        default_locale = "en";
        theme_args.simple_style = "dark";
      };
    };
    environmentFile = config.sops.secrets.searx-env.path;
  };

  users.groups.ollama = { };
  users.users.ollama = {
    description = "ollama user";
    isSystemUser = true;
    group = "ollama";
    extraGroups = [ "video" "render" ];
  };

  systemd.services.ollama.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "ollama";
    Group = "ollama";
  };
  systemd.services.open-webui.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "ollama";
    Group = "ollama";
  };

  persist.state.directories = [
    "/var/lib/ollama"
    "/var/lib/open-webui"
  ];
}