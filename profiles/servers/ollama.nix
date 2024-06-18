{ config, lib, ... }:
let
  gpu = config.deviceSpecific.devInfo.gpu.vendor;
in {
  services.ollama = {
    enable = true;
    host = "127.0.0.1";
    port = 11434;
    sandbox = false;
    acceleration =
      if gpu == "amd" then
        "rocm"
      else if gpu == "nvidia" then
        "cuda"
      else false;
    openFirewall = false;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      OLLAMA_KEEP_ALIVE = "-1";
      # OLLAMA_LLM_LIBRARY = "";
    };
  };
  services.open-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8081;
    openFirewall = false;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # Disable authentication
      WEBUI_AUTH = "False";
    };
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