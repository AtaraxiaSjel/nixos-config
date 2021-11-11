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
      extensions = with pkgs.vscode-extensions; ([
        alefragnani.project-manager
        arrterian.nix-env-selector
        bbenoist.nix
        codezombiech.gitignore
        coenraads.bracket-pair-colorizer-2
        eamodio.gitlens
        github.vscode-pull-request-github
        mhutchie.git-graph
        ms-vscode-remote.remote-ssh
        naumovs.color-highlight
        shardulm94.trailing-spaces
        streetsidesoftware.code-spell-checker
        tomoki1207.pdf
        yzhang.markdown-all-in-one
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "awesome-flutter-snippets";
          publisher = "nash";
          version = "3.0.2";
          sha256 = "sha256-GQ42tySMD74F0umBlfBCbcjRsop8lKn/9RrwFM40PwE=";
        } {
          name = "better-comments";
          publisher = "aaron-bond";
          version = "2.1.0";
          sha256 = "sha256-l7MG2bpfTgVgC+xLal6ygbxrrRoNONzOWjs3fZeZtU4=";
        } {
          name = "better-toml";
          publisher = "bungcip";
          version = "0.3.2";
          sha256 = "sha256-g+LfgjAnSuSj/nSmlPdB0t29kqTmegZB5B1cYzP8kCI=";
        } {
          name = "bookmarks";
          publisher = "alefragnani";
          version = "13.2.2";
          sha256 = "sha256-pdZi+eWLPuHp94OXpIlOOS29IGgze4dNd4DWlCGa3p0=";
        } {
          name = "codeacejumper";
          publisher = "lucax88x";
          version = "3.3.2";
          sha256 = "sha256-Fltl6ryBK2g2WWxV2Ru74cSYwqxgfFGclLlm8ChwRQk=";
        } {
          name = "dart-code";
          publisher = "dart-code";
          version = "3.28.0";
          sha256 = "sha256-m0cZLAlVtjfvkIXlFssDQcNhqpjRrW1JTaUsohnY/14=";
        } {
          name = "vscode-env";
          publisher = "irongeek";
          version = "0.1.0";
          sha256 = "sha256-URq90lOFtPCNfSIl2NUwihwRQyqgDysGmBc3NG7o7vk=";
        } {
          name = "flutter";
          publisher = "dart-code";
          version = "3.28.0";
          sha256 = "sha256-3+PGSuJe32F2i1g9+/6GkcSYEMsjXZMK4xv4xPjzXvM=";
        } {
          name = "flutter-tree";
          publisher = "marcelovelasquez";
          version = "1.0.0";
          sha256 = "sha256-+gQH7so9m/HvO0tDKaiNTP+2pTCvNdecJK60sgTY9CE=";
        } {
          name = "gruvbox-material";
          publisher = "sainnhe";
          version = "6.4.6";
          sha256 = "sha256-rm/S4SAZ/z8Svd0wZyaYOZUxcUSMmBE0xUk+16drrZ8=";
        } {
          name = "vscode-hexdump";
          publisher = "slevesque";
          version = "1.8.1";
          sha256 = "sha256-BNPRXRiM0OujxUZhBHREtaa0VrbuhhQ2CG3PUCyxga8=";
        } {
          name = "material-icon-theme";
          publisher = "pkief";
          version = "4.10.0";
          sha256 = "sha256-4CzjUz/n/lQ7tLXuKEzmSkSE1jinpTZWDy11KHq7P4U=";
        } {
          name = "path-intellisense";
          publisher = "christian-kohler";
          version = "2.4.2";
          sha256 = "sha256-bPemoDmhBANjbn19ThKTZEjKLbQ5SlVFJp22K4kNjag=";
        } {
          name = "plantuml";
          publisher = "jebbs";
          version = "2.16.0";
          sha256 = "sha256-E29zGwHzVTARVGKn0JHpyKx3NCBNUSUSngmUvi0Hfo8=";
        } {
          name = "code-spell-checker-russian";
          publisher = "streetsidesoftware";
          version = "2.0.1";
          sha256 = "sha256-GC1zQp/2BxPLrCBCgKhxHkvX0bM3OAYSvI2C9SSHthQ=";
        } {
          name = "tokyo-night";
          publisher = "enkia";
          version = "0.7.9";
          sha256 = "sha256-2+md3lkBew1u+XkAM4e7i4OMNvyyJlZA4OT3WvMUkfk=";
        } {
          name = "wal-theme";
          publisher = "dlasagno";
          version = "1.2.0";
          sha256 = "sha256-X16N5ClNVLtWST64ybJUEIRo6WgDCzODhBA9ScAHI5w=";
        }
      ];
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
        "remote.SSH.configFile" = "/home/alukard/.ssh/remote_config";
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
