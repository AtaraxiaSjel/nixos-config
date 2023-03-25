{ pkgs, lib, config, inputs, ... }:
let
  thmFile = config.lib.base16.templateFile;
  thm = config.lib.base16.theme;
  EDITOR = pkgs.writeShellScript "code-editor" ''
    source "/etc/profiles/per-user/${config.mainuser}/etc/profile.d/hm-session-vars.sh"
    NIX_OZONE_WL=1 \
    exec \
    ${config.home-manager.users.${config.mainuser}.programs.vscode.package}/bin/code \
    -w -n \
    "$@"
  '';
in
{
  defaultApplications.editor = {
    cmd = "${EDITOR}";
    desktop = "code-wayland";
  };

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
          vscode.bungcip.better-toml
          vscode.catppuccin.catppuccin-vsc
          vscode.christian-kohler.path-intellisense
          vscode.codezombiech.gitignore
          vscode.dart-code.dart-code
          # dlasagno.wal-theme
          vscode.eamodio.gitlens-insiders
          vscode.enkia.tokyo-night
          vscode.felixangelov.bloc
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
          nixpkgs.rust-lang.rust-analyzer

          # Django
          nixpkgs.ms-python.python
          vscode.monosans.djlint
          vscode.ms-python.isort
          vscode.ms-python.vscode-pylance
          vscode.thebarkman.vscode-djaneiro
        ];
      # mutableExtensionsDir = false;
      userSettings = {
        "update.mode" = "none";
        "telemetry.telemetryLevel" = "off";
        #"editor.fontFamily" = "'Victor Mono Nerd Font', 'Fira Code', 'Font Awesome 5 Free', 'Font Awesome 5 Free Solid', 'Material Icons'";
        "editor.fontFamily" = "'VictorMono Nerd Font Medium'";
        "editor.fontLigatures" = true;
        #"editor.fontWeight" = "600";
        "editor.fontSize" = 16;
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.colorTheme" = "Tokyo Night";
        "files.autoSave" = "afterDelay";
        "cSpell.language" = "en,ru";
        "editor.quickSuggestions" = {
            "other" = true;
            "comments" = false;
            "strings" = true;
        };
        "files.trimTrailingWhitespace" = true;
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
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${inputs.rnix-lsp.defaultPackage.${pkgs.system}}/bin/rnix-lsp";
        # "nix.formatterPath" = "nixfmt";
        "dart.allowAnalytics" = false;
        "dart.flutterCreateOrganization" = "com.ataraxiadev";
        "files.exclude" = {
            "**/.classpath" = true;
            "**/.project" = true;
            "**/.settings" = true;
            "**/.factorypath" = true;
            "**/.direnv" = true;
        };
        "gruvboxMaterial.darkContrast" = "medium";
        "dart.debugSdkLibraries" = true;
        "dart.checkForSdkUpdates" = false;
        "window.menuBarVisibility" = "toggle";
        "terminal.integrated.fontFamily" = "FiraCode Nerd Font";
        "terminal.integrated.fontWeight" = "500";
        "files.watcherExclude" = {
            "**/.direnv" = true;
        };
        "search.exclude" = {
            "**/.direnv" = true;
        };
        "git.autofetch" = false;
        "git.enableCommitSigning" = true;
        "git-graph.repository.sign.commits" = true;
        "git-graph.repository.sign.tags" = true;
        # "editor.bracketPairColorization.enabled" = false;
        "editor.guides.bracketPairs" = "active";
        "terminal.integrated.defaultProfile.linux" = "zsh";
        "terminal.integrated.profiles.linux".zsh.path = "/run/current-system/sw/bin/zsh";
        "security.workspace.trust.untrustedFiles" = "open";
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
