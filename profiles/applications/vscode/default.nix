{ pkgs, lib, config, inputs, ... }:
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

  ext-vscode = inputs.nix-vscode-marketplace.extensions.${pkgs.system}.vscode-marketplace;
  ext-nixpkgs = pkgs.vscode-extensions;

  continue-ver = lib.getVersion ext-vscode.continue.continue;
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
  ];

  home-manager.users.${config.mainuser} = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      extensions = [
          ext-vscode.aaron-bond.better-comments
          # ext-vscode.alefragnani.bookmarks
          # ext-vscode.alefragnani.project-manager
          # ext-vscode.alexisvt.flutter-snippets
          ext-vscode.christian-kohler.path-intellisense
          ext-vscode.codezombiech.gitignore
          ext-vscode.continue.continue
          # ext-vscode.dart-code.dart-code
          # ext-vscode.dart-code.flutter
          ext-vscode.eamodio.gitlens
          ext-vscode.enkia.tokyo-night
          # ext-vscode.felixangelov.bloc
          ext-vscode.github.vscode-github-actions
          ext-vscode.github.vscode-pull-request-github
          ext-vscode.gruntfuggly.todo-tree
          ext-vscode.irongeek.vscode-env
          ext-vscode.jebbs.plantuml
          ext-vscode.jnoortheen.nix-ide
          # ext-vscode.lucax88x.codeacejumper
          # ext-vscode.marcelovelasquez.flutter-tree
          ext-vscode.mhutchie.git-graph
          ext-vscode.mkhl.direnv
          ext-vscode.ms-azuretools.vscode-docker
          ext-nixpkgs.ms-python.python
          ext-vscode.ms-python.isort
          ext-vscode.ms-python.vscode-pylance
          ext-vscode.ms-vscode.hexeditor
          ext-nixpkgs.ms-vscode-remote.remote-ssh #FIX later
          ext-vscode.pkief.material-icon-theme
          ext-vscode.streetsidesoftware.code-spell-checker
          ext-vscode.streetsidesoftware.code-spell-checker-russian
          ext-vscode.ultram4rine.vscode-choosealicense
          ext-vscode.usernamehw.errorlens
          ext-vscode.yzhang.markdown-all-in-one
          # Rust
          ext-vscode.jscearcy.rust-doc-viewer
          ext-vscode.polypus74.trusty-rusty-snippets
          ext-nixpkgs.rust-lang.rust-analyzer
          ext-vscode.serayuzgur.crates
          ext-vscode.tamasfe.even-better-toml
          ext-vscode.vadimcn.vscode-lldb
          # Golang
          ext-vscode.golang.go
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
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = ["${pkgs.nixfmt-rfc-style}/bin/nixfmt"];
            };
            "nix" = {
              "maxMemoryMB" = 4096;
              "flake" = {
                "autoEvalInputs" = true;
              };
            };
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
}
