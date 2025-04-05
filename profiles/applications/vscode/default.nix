{
  pkgs,
  lib,
  config,
  inputs,
  self-nixpkgs,
  ...
}:
let
  EDITOR = pkgs.writeShellScript "code-editor" ''
    source "/etc/profiles/per-user/${config.mainuser}/etc/profile.d/hm-session-vars.sh"
    NIXOS_OZONE_WL=1 \
    exec \
    ${config.home-manager.users.${config.mainuser}.programs.vscode.package}/bin/code \
    --password-store="gnome-libsecret" \
    -w -n \
    "$@"
  '';

  pkgs-ext = import self-nixpkgs {
    inherit (pkgs) system;
    config.allowUnfree = true;
    overlays = [ inputs.nix-vscode-marketplace.overlays.default ];
  };

  continue-ver = lib.getVersion pkgs-ext.vscode-extensions.continue.continue;
in
{
  environment.sessionVariables = {
    EDITOR = config.defaultApplications.editor.cmd;
    VISUAL = config.defaultApplications.editor.cmd;
  };

  defaultApplications.editor = {
    cmd = "${EDITOR}";
    desktop = "code-wayland";
  };

  persist.state.homeDirectories = [
    ".config/Code"
    ".continue"
  ];

  home-manager.users.${config.mainuser} = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions =
          let
            ext-market = pkgs-ext.vscode-marketplace;
            ext-nixpkgs = pkgs-ext.vscode-extensions;
          in
          [
            ext-market.aaron-bond.better-comments
            # ext-market.alefragnani.bookmarks
            # ext-market.alefragnani.project-manager
            # ext-market.alexisvt.flutter-snippets
            ext-market.christian-kohler.path-intellisense
            ext-market.codezombiech.gitignore
            ext-nixpkgs.continue.continue
            # ext-market.dart-code.dart-code
            # ext-market.dart-code.flutter
            ext-market.eamodio.gitlens
            ext-market.enkia.tokyo-night
            # ext-market.felixangelov.bloc
            ext-market.fill-labs.dependi
            ext-market.github.vscode-github-actions
            ext-market.github.vscode-pull-request-github
            ext-market.gruntfuggly.todo-tree
            ext-market.irongeek.vscode-env
            ext-market.jebbs.plantuml
            ext-market.jnoortheen.nix-ide
            # ext-market.lucax88x.codeacejumper
            # ext-market.marcelovelasquez.flutter-tree
            ext-market.mhutchie.git-graph
            ext-market.mkhl.direnv
            ext-market.ms-azuretools.vscode-docker
            ext-nixpkgs.ms-python.python
            ext-market.ms-python.isort
            ext-market.ms-python.vscode-pylance
            ext-nixpkgs.ms-vscode.cpptools
            ext-market.ms-vscode.hexeditor
            ext-nixpkgs.ms-vscode-remote.remote-containers
            ext-nixpkgs.ms-vscode-remote.remote-ssh # FIX later
            ext-market.pkief.material-icon-theme
            ext-market.streetsidesoftware.code-spell-checker
            ext-market.streetsidesoftware.code-spell-checker-russian
            ext-market.ultram4rine.vscode-choosealicense
            ext-market.usernamehw.errorlens
            ext-market.yzhang.markdown-all-in-one
            # Rust
            ext-market.jscearcy.rust-doc-viewer
            ext-market.polypus74.trusty-rusty-snippets
            ext-nixpkgs.rust-lang.rust-analyzer
            ext-market.tamasfe.even-better-toml
            ext-market.vadimcn.vscode-lldb
            # Golang
            ext-market.golang.go
            # Zig
            ext-market.ziglang.vscode-zig
          ];
        # mutableExtensionsDir = false;
        userSettings = {
          "continue.telemetryEnabled" = false;
          "dart.checkForSdkUpdates" = false;
          "dart.debugSdkLibraries" = true;
          "dart.flutterCreateOrganization" = "com.ataraxiadev";
          "dart.flutterCreatePlatforms" = [ "linux,web,windows" ];
          "dart.flutterScreenshotPath" = "/home/${config.mainuser}/Pictures/flutter";
          "dart.openDevTools" = "flutter";
          "dart.runPubGetOnNestedProjects" = "below";
          "dart.showTodos" = true;
          "editor.fontFamily" = "'VictorMono Nerd Font Medium'";
          "editor.fontLigatures" = true;
          "editor.fontSize" = 16;
          "editor.guides.bracketPairs" = "active";
          "editor.quickSuggestions" = {
            "other" = true;
            "comments" = false;
            "strings" = true;
          };
          "files.autoSave" = "afterDelay";
          "files.exclude" = {
            "**/.classpath" = true;
            "**/.project" = true;
            "**/.settings" = true;
            "**/.factorypath" = true;
            "**/.direnv" = true;
          };
          "files.trimTrailingWhitespace" = true;
          "files.watcherExclude" = {
            "**/.direnv" = true;
          };
          "git-graph.repository.sign.commits" = true;
          "git-graph.repository.sign.tags" = true;
          "git.autofetch" = false;
          "git.enableCommitSigning" = true;
          "go.useLanguageServer" = true;
          "gopls" = {
            "ui.semanticTokens" = true;
            "formatting.gofumpt" = true;
            "ui.diagnostic.staticcheck" = true;
          };
          "license.author" = "Dmitriy <ataraxiadev@ataraxiadev.com>";
          "license.default" = "mit";
          "license.extension" = ".md";
          "license.year" = "auto";
          "nix.enableLanguageServer" = true;
          "nix.formatterPath" = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          "nix.serverPath" = "${pkgs.nil}/bin/nil";
          # "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
          "nix.serverSettings" = {
            "nil" = {
              "formatting" = {
                "command" = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
              };
              # "nix" = {
              #   "maxMemoryMB" = 4096;
              #   "flake" = {
              #     "autoEvalInputs" = true;
              #   };
              # };
            };
            "nixd" = {
              "formatting" = {
                "command" = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
              };
              # "options" = {
              #   "nixos" = {
              #     "expr" = "";
              #   };
              #   "home-manager" = {
              #     "expr" = "";
              #   };
              # };
            };
          };
          "rust-analyzer.check.command" = "clippy";
          "search.exclude" = {
            "**/.direnv" = true;
          };
          "security.workspace.trust.untrustedFiles" = "open";
          "telemetry.telemetryLevel" = "off";
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "terminal.integrated.fontFamily" = "FiraCode Nerd Font";
          "terminal.integrated.fontWeight" = "500";
          "terminal.integrated.profiles.linux".zsh.path = "/run/current-system/sw/bin/zsh";
          "terminal.integrated.scrollback" = 100000;
          "todo-tree.regex.regex" = "(//|#|<!--|;|/\\*|^|^[ \\t]*(-|\\d+.))\\s*($TAGS)|todo!";
          "update.mode" = "none";
          "window.menuBarVisibility" = "toggle";
          "window.titleBarStyle" = "custom";
          "workbench.colorTheme" = "Tokyo Night";
          "workbench.iconTheme" = "material-icon-theme";
          "zig.path" = "zig";
          "zig.zls.path" = "zls";
          "zig.initialSetupDone" = true;
          "[dart]" = {
            "editor.formatOnSave" = true;
            "editor.formatOnType" = true;
            "editor.rulers" = [
              80
            ];
            "editor.selectionHighlight" = false;
            "editor.suggest.snippetsPreventQuickSuggestions" = false;
            "editor.suggestSelection" = "first";
            "editor.tabCompletion" = "onlySnippets";
            "editor.wordBasedSuggestions" = "off";
          };
          "[nix]" = {
            "editor.tabSize" = 2;
            "editor.detectIndentation" = true;
          };
          "[rust]" = {
            "editor.defaultFormatter" = "rust-lang.rust-analyzer";
            "editor.formatOnSave" = true;
          };
          "python.analysis.extraPaths" = [
            "/home/${config.mainuser}/.vscode/extensions/continue.continue"
            "/home/${config.mainuser}/.vscode/extensions/continue.continue-${continue-ver}-linux-x64"
          ];
        };
      };
    };
  };
}
