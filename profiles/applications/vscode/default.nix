{ pkgs, lib, config, ... }:
let
  thmFile = config.lib.base16.templateFile;
  thm = config.lib.base16.theme;
in
{
  home-manager.users.alukard = {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix);
      userSettings = {
        "update.mode" = "none";
        "telemetry.telemetryLevel" = "off";
        "editor.fontFamily" = "'Victor Mono', 'Fira Code', 'Font Awesome 5 Free', 'Font Awesome 5 Free Solid', 'Material Icons'";
        "editor.fontLigatures" = true;
        "editor.fontWeight" = "600";
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
        "hexdump.littleEndian" = true;
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
        "terminal.integrated.fontFamily" = "IBM Plex Mono for Powerline";
        "terminal.integrated.fontWeight" = "500";
        "files.watcherExclude" = {
            "**/.direnv" = true;
        };
        "search.exclude" = {
            "**/.direnv" = true;
        };
        "git.enableCommitSigning" = true;
        "git-graph.repository.sign.commits" = true;
        "git-graph.repository.sign.tags" = true;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "terminal.integrated.defaultProfile.linux" = "linux-zsh";
        "terminal.integrated.profiles.linux" = {
          "linux-zsh" = {
            "path" = "${pkgs.zsh}/bin/zsh";
          };
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

  defaultApplications.editor = {
    cmd = "${pkgs.vscode}/bin/code";
    desktop = "code";
  };
}
