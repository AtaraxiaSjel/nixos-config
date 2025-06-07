{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe mkEnableOption mkIf;
  inherit (config.theme) fonts;
  cfg = config.ataraxia.programs.vscode;

  EDITOR = pkgs.writeShellScript "code-editor" ''
    source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    NIXOS_OZONE_WL=1 \
    exec \
    ${getExe config.programs.vscode.package} \
    --password-store="gnome-libsecret" \
    -w -n \
    "$@"
  '';
in
{
  options.ataraxia.programs.vscode = {
    enable = mkEnableOption "Enable vscode program";
  };

  config = mkIf cfg.enable {
    defaultApplications.editor = {
      cmd = EDITOR;
      desktop = "code-wayland";
    };

    home.sessionVariables = {
      EDITOR = config.defaultApplications.editor.cmd;
      VISUAL = config.defaultApplications.editor.cmd;
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions =
          let
            ext-market = pkgs.nix-vscode-extensions.vscode-marketplace;
            ext-nixpkgs = pkgs.vscode-extensions;
          in
          with ext-market;
          [
            aaron-bond.better-comments
            catppuccin.catppuccin-vsc-icons
            christian-kohler.path-intellisense
            codezombiech.gitignore
            eamodio.gitlens
            enkia.tokyo-night
            fill-labs.dependi
            github.vscode-github-actions
            github.vscode-pull-request-github
            gruntfuggly.todo-tree
            irongeek.vscode-env
            jebbs.plantuml
            jnoortheen.nix-ide
            mhutchie.git-graph
            mkhl.direnv
            ms-azuretools.vscode-docker
            ms-python.isort
            ms-python.python
            ms-python.vscode-pylance
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh
            ms-vscode.cpptools
            ms-vscode.hexeditor
            pkief.material-icon-theme
            tamasfe.even-better-toml
            ultram4rine.vscode-choosealicense
            usernamehw.errorlens
            yzhang.markdown-all-in-one
            # Rust
            jscearcy.rust-doc-viewer
            polypus74.trusty-rusty-snippets
            rust-lang.rust-analyzer
            ext-nixpkgs.vadimcn.vscode-lldb
          ];
        # mutableExtensionsDir = false;
        userSettings = {
          "editor.fontFamily" = fonts.mono.family;
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
            "**/.devenv" = true;
            "**/.direnv" = true;
            "**/.factorypath" = true;
            "**/.project" = true;
            "**/.settings" = true;
          };
          "files.trimTrailingWhitespace" = true;
          "files.watcherExclude" = {
            "**/.devenv" = true;
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
          "nix.formatterPath" = getExe pkgs.nixfmt-rfc-style;
          # "nix.serverPath" = getExe pkgs.nil;
          "nix.serverPath" = getExe pkgs.nixd;
          "nix.serverSettings" = {
            "nil" = {
              "formatting" = {
                "command" = [ (getExe pkgs.nixfmt-rfc-style) ];
              };
            };
            "nixd" = {
              "formatting" = {
                "command" = [
                  (getExe pkgs.nixfmt-rfc-style)
                ];
              };
            };
          };
          "rust-analyzer.check.command" = "clippy";
          "search.exclude" = {
            "**/.devenv" = true;
            "**/.direnv" = true;
          };
          "security.workspace.trust.untrustedFiles" = "open";
          "telemetry.telemetryLevel" = "off";
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "terminal.integrated.fontFamily" = fonts.mono.family;
          "terminal.integrated.fontWeight" = "500";
          "terminal.integrated.profiles.linux".zsh.path = "/run/current-system/sw/bin/zsh";
          "terminal.integrated.scrollback" = 100000;
          "todo-tree.regex.regex" = "(//|#|<!--|;|/\\*|^|^[ \\t]*(-|\\d+.))\\s*($TAGS)|todo!";
          "update.mode" = "none";
          "window.menuBarVisibility" = "toggle";
          "window.titleBarStyle" = "custom";
          "workbench.colorTheme" = lib.mkDefault "Tokyo Night";
          "workbench.iconTheme" = lib.mkDefault "material-icon-theme";
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
    };

    persist.state.directories = [
      ".config/Code"
    ];
  };
}
