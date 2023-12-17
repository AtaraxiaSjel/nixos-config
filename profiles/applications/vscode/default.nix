{ pkgs, lib, config, inputs, ... }:
let
  thmFile = config.lib.base16.templateFile;
  thm = config.lib.base16.theme;
  EDITOR = pkgs.writeShellScript "code-editor" ''
    source "/etc/profiles/per-user/${config.mainuser}/etc/profile.d/hm-session-vars.sh"
    NIXOS_OZONE_WL=1 \
    exec \
    ${config.home-manager.users.${config.mainuser}.programs.vscode.package}/bin/code \
    --password-store="gnome-libsecret" \
    -w -n \
    "$@"
  '';
in
{
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
      extensions = let
          vscode = inputs.nix-vscode-marketplace.extensions.${pkgs.system}.vscode-marketplace;
          open-vsx = inputs.nix-vscode-marketplace.extensions.${pkgs.system}.open-vsx;
          nixpkgs = pkgs.vscode-extensions;
        in [
          # (pkgs.callPackage ./theme.nix { mainuser = config.mainuser; } config.lib.base16.theme)
          vscode.aaron-bond.better-comments
          vscode.alefragnani.bookmarks
          vscode.alefragnani.project-manager
          vscode.alexisvt.flutter-snippets
          vscode.christian-kohler.path-intellisense
          vscode.codezombiech.gitignore
          vscode.continue.continue
          vscode.dart-code.dart-code
          vscode.dart-code.flutter
          # vscode.dlasagno.wal-theme
          vscode.eamodio.gitlens
          vscode.enkia.tokyo-night
          vscode.felixangelov.bloc
          vscode.github.vscode-github-actions
          vscode.github.vscode-pull-request-github
          vscode.irongeek.vscode-env
          vscode.jebbs.plantuml
          vscode.jnoortheen.nix-ide
          vscode.lucax88x.codeacejumper
          vscode.marcelovelasquez.flutter-tree
          vscode.mhutchie.git-graph
          vscode.mkhl.direnv
          vscode.ms-azuretools.vscode-docker
          vscode.ms-vscode.hexeditor
          nixpkgs.ms-vscode-remote.remote-ssh #FIX later
          vscode.pkief.material-icon-theme
          vscode.streetsidesoftware.code-spell-checker
          vscode.streetsidesoftware.code-spell-checker-russian
          vscode.ultram4rine.vscode-choosealicense
          vscode.yzhang.markdown-all-in-one
          # Django
          nixpkgs.ms-python.python
          vscode.monosans.djlint
          vscode.ms-python.isort
          vscode.ms-python.vscode-pylance
          vscode.thebarkman.vscode-djaneiro
          # Latex
          vscode.james-yu.latex-workshop
          # Rust
          vscode.gruntfuggly.todo-tree
          vscode.jscearcy.rust-doc-viewer
          vscode.polypus74.trusty-rusty-snippets
          vscode.rust-lang.rust-analyzer
          vscode.serayuzgur.crates
          vscode.tamasfe.even-better-toml
          vscode.usernamehw.errorlens
          vscode.vadimcn.vscode-lldb
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
        "license.author" = "Dmitriy <ataraxiadev@ataraxiadev.com>";
        "license.default" = "mit";
        "license.extension" = ".md";
        "license.year" = "auto";
        "nix.enableLanguageServer" = true;
        "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = ["${pkgs.nixfmt}/bin/nixfmt"];
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
        "todo-tree.regex.regex" = "(//|#|<!--|;|/\\*|^|^[ \\t]*(-|\\d+.))\\s*($TAGS)|todo!";
        "update.mode" = "none";
        # Temp fix crash on startup
        # See https://github.com/microsoft/vscode/issues/184124
        "window.menuBarVisibility" = "toggle";
        "window.titleBarStyle" = "custom";
        ###
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
          "editor.wordBasedSuggestions" = false;
        };
        "[nix]" = {
          "editor.tabSize" = 2;
          "editor.detectIndentation" = true;
        };
        "[rust]" = {
          "editor.defaultFormatter" = "rust-lang.rust-analyzer";
          "editor.formatOnSave" = true;
        };
      };
    };

    home.file.".cache/wal/colors".text = ''
      #${thm.base00-hex}
      #${thm.base08-hex}
      #${thm.base0B-hex}
      #${thm.base0A-hex}
      #${thm.base0D-hex}
      #${thm.base0E-hex}
      #${thm.base0C-hex}
      #${thm.base05-hex}
      #${thm.base03-hex}
      #${thm.base08-hex}
      #${thm.base0B-hex}
      #${thm.base0A-hex}
      #${thm.base0D-hex}
      #${thm.base0E-hex}
      #${thm.base0C-hex}
      #${thm.base07-hex}
    '';
  };
}
