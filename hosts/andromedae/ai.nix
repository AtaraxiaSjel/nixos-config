{
  config,
  lib,
  pkgs,
  inputs,
  secretsDir,
  ...
}:
let
  toRelativeHome = path: lib.removePrefix "/" (lib.removePrefix config.home.homeDirectory path);

  opencode-wrapped = pkgs.symlinkJoin {
    inherit (pkgs.opencode) meta version;
    name = "${lib.getName pkgs.opencode}-wrapped-${lib.getVersion pkgs.opencode}";
    paths = [ pkgs.opencode ];
    preferLocalBuild = true;
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/opencode \
        --run 'export NORDROUTER_API_KEY="$(cat ${config.sops.secrets.nordrouter-apikey.path})"' \
        --run 'export COMMANDCODE_API_KEY="$(cat ${config.sops.secrets.commandcode-apikey.path})"' \
        --run 'export OPENCODE_ENABLE_EXA=1'
    '';
  };

  pi-coding-agent-wrapped =
    extraPkgs:
    pkgs.symlinkJoin {
      inherit (pkgs.pi-coding-agent) meta version;
      name = "${lib.getName pkgs.pi-coding-agent}-wrapped-${lib.getVersion pkgs.pi-coding-agent}";
      paths = [ pkgs.pi-coding-agent ];
      preferLocalBuild = true;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --suffix PATH : ${lib.makeBinPath extraPkgs}
      '';
    };

  gatewayPort = config.services.mcp-gateway.settings.server.port or 39400;
  piConfigDir = "${config.xdg.configHome}/pi/agent";
  opencodeConfigPath = "${config.xdg.configHome}/opencode/opencode.json";
in
{
  imports = [
    inputs.ataraxiasjel-nur.homeManagerModules.mcp-gateway
  ];

  home.packages = with pkgs; [
    (pi-coding-agent-wrapped [
      (python3.withPackages (
        ps: with ps; [
          virtualenv
        ]
      ))
      nodejs
      uv
    ])
  ];
  home.sessionVariables = {
    PI_CODING_AGENT_DIR = piConfigDir;
  };

  sops.age.keyFile = "/home/${config.home.username}/.config/sops/age/keys.txt";
  sops.secrets.nordrouter-apikey.sopsFile = secretsDir + /ai.yaml;
  sops.secrets.commandcode-apikey.sopsFile = secretsDir + /ai.yaml;
  sops.secrets.mcp-gateway.sopsFile = secretsDir + /ai.yaml;

  virtualisation.quadlet.containers.cc-proxy = {
    autoStart = true;
    serviceConfig = {
      RestartSec = "10";
      Restart = "always";
    };
    containerConfig = {
      image = "ghcr.io/maxeaglet/commandcode-proxy:release";
      environments.PORT = "3050";
      autoUpdate = "registry";
      publishPorts = [ "127.0.0.1:3050:3050/tcp" ];
    };
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencode-wrapped;
    extraPackages = with pkgs; [
      (python3.withPackages (
        ps: with ps; [
          virtualenv
        ]
      ))
      nodejs
      uv
    ];
    web = {
      enable = true;
      extraArgs = [
        "--port"
        "4096"
      ];
    };
    settings = {
      small_model = "opencode/deepseek-v4-flash-free";
      model = "opencode/deepseek-v4-flash-free";
      compaction = {
        auto = true;
        prune = true;
        reserved = 8192;
      };
      provider = {
        commandcode = {
          models = {
            "deepseek/deepseek-v4.1-flash" = {
              name = "DeepSeek V4.1 Flash";
              options = {
                reasoningEffort = "high";
              };
              limit = {
                context = 262144;
                output = 65536;
              };
              cost = {
                input = 0.15;
                output = 0.6;
                cache_read = 0.003;
              };
              variants = {
                max = {
                  reasoningEffort = "max";
                };
                high = {
                  reasoningEffort = "high";
                };
                low = {
                  reasoningEffort = "low";
                };
                none = {
                  reasoningEffort = "none";
                };
              };
            };
            "meta/muse-spark-1.3-contributor" = {
              name = "Muse Spark 1.3 Contributor";
              options = {
                reasoningEffort = "high";
              };
              limit = {
                context = 262144;
                output = 65536;
              };
              cost = {
                input = 0.1;
                output = 0.2;
                cache_read = 0.002;
              };
              variants = {
                xhigh = {
                  reasoningEffort = "xhigh";
                };
                high = {
                  reasoningEffort = "high";
                };
                medium = {
                  reasoningEffort = "medium";
                };
                low = {
                  reasoningEffort = "low";
                };
                none = {
                  reasoningEffort = "none";
                };
              };
            };
            "z-ai/glm-5.3-flash" = {
              name = "GLM-5.3 Flash";
              options = {
                reasoningEffort = "high";
              };
              limit = {
                context = 262144;
                output = 65536;
              };
              cost = {
                input = 0.15;
                output = 0.5;
                cache_read = 0.03;
              };
              variants = {
                max = {
                  reasoningEffort = "max";
                };
                high = {
                  reasoningEffort = "high";
                };
                low = {
                  reasoningEffort = "low";
                };
                none = {
                  reasoningEffort = "none";
                };
              };
            };
          };
          name = "CommandCode";
          npm = "@ai-sdk/openai-compatible";
          options = {
            apiKey = "{env:COMMANDCODE_API_KEY}";
            baseURL = "http://localhost:3050/v1";
          };
        };
        nordrouter = {
          npm = "@ai-sdk/openai-compatible";
          name = "NordRouter";
          options = {
            baseURL = "https://nordrouter.com/v1";
            apiKey = "{env:NORDROUTER_API_KEY}";
            timeout = 600000;
            chunkTimeout = 30000;
          };
          models = {
            "google/gemini-3.8-flash:flex" = {
              name = "Gemini 3.8 Flash (Flex)";
              limit = {
                context = 131072;
                output = 32768;
              };
              options = {
                reasoningEffort = "medium";
              };
              variants = {
                minimal.reasoningEffort = "none";
                low.reasoningEffort = "low";
                medium.reasoningEffort = "medium";
                high.reasoningEffort = "high";
              };
            };
            "deepseek/deepseek-v4-flash-0731" = {
              name = "DeepSeek V4 Flash 0731";
              limit = {
                context = 131072;
                output = 65536;
              };
              options = {
                reasoningEffort = "max";
              };
              variants = {
                low.reasoningEffort = "low";
                high.reasoningEffort = "high";
                max.reasoningEffort = "max";
              };
            };
          };
        };
      };
    };
    # agents = {};
    # context = "";
    # commands = {};
    # skills = {};
    # tools = {};
  };

  services.mcp-gateway = {
    enable = true;
    environmentFile = config.sops.secrets.mcp-gateway.path;
    stateDir = "${config.xdg.stateHome}/mcp-gateway";
    settings = {
      server = {
        host = "127.0.0.1";
        port = 39400;
      };
      meta_mcp = {
        enabled = true;
        cache_tools = true;
      };
      backends = {
        cargo-doc = {
          command = lib.getExe pkgs.cargo-doc-mcp;
          description = "Access cargo doc";
        };
        context7 = {
          http_url = "https://mcp.context7.com/mcp";
          description = "Documentation lookup";
          streamable_http = true;
          headers.CONTEXT7_API_KEY = "\${CONTEXT7_API_KEY}";
        };
        fetch = {
          command = lib.getExe pkgs.mcp-server-fetch;
          description = "Fetch URLs as markdown";
        };
        git = {
          command = lib.getExe pkgs.mcp-server-git;
          description = "Git operations";
        };
        github = {
          command = "${lib.getExe pkgs.github-mcp-server} stdio";
          description = "GitHub MCP Server";
          env.GITHUB_PERSONAL_ACCESS_TOKEN = "env:GITHUB_MCP_PAT";
        };
        nixos = {
          command = lib.getExe pkgs.mcp-nixos;
          description = "NixOS options and packages";
        };
        searxng = {
          command = lib.getExe pkgs.mcp-server-searxng;
          description = "SearXNG search";
          env.SEARXNG_INSTANCES = "https://search.ataraxiadev.com";
        };
        skim = {
          http_url = "https://skim.perch-app.workers.dev/mcp";
          description = "URL to markdown";
          streamable_http = true;
        };
        timezone = {
          command = lib.getExe pkgs.mcp-server-time;
          description = "Timezone conversion";
        };
      };
    };
  };

  programs.mcp = {
    enable = true;
    servers = {
      gateway = {
        url = "http://127.0.0.1:${toString gatewayPort}/mcp";
      };
    };
  };

  persist.state.directories = [
    ".config/opencode"
    ".local/share/opencode"
  ]
  ++ (map (x: toRelativeHome x) [
    piConfigDir
    config.services.mcp-gateway.stateDir
  ]);

  # https://github.com/nix-community/home-manager/issues/9397
  xdg.configFile."opencode/opencode.json".enable = false;
  home.activation.opencodeMutableConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    configFile=${lib.escapeShellArg opencodeConfigPath}
    staticJson="$(mktemp)"
    existingJson="$(mktemp)"
    mergedJson="$(mktemp)"

    existingConfig=/dev/null
    if [ -f "$configFile" ] && [ ! -L "$configFile" ]; then
      existingConfig="$configFile"
    fi

    cp ${lib.escapeShellArg config.xdg.configFile."opencode/opencode.json".source} "$staticJson"

    # /dev/null → null in jq; default to {} so merge still works
    if [ ! -s "$existingJson" ]; then
      echo '{}' > "$existingJson"
    fi

    ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$existingJson" "$staticJson" > "$mergedJson"
    install -Dm644 "$mergedJson" "$configFile"
    rm -f "$existingJson" "$staticJson" "$mergedJson"
  '';
}
