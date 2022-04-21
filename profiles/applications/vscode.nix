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
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "better-comments";
          publisher = "aaron-bond";
          version = "2.1.0";
          sha256 = "0kmmk6bpsdrvbb7dqf0d3annpg41n9g6ljzc1dh0akjzpbchdcwp";
        }
        {
          name = "Bookmarks";
          publisher = "alefragnani";
          version = "13.2.4";
          sha256 = "0376hs09wypn781s4cz3qb74qvsxck0nw1s39bfsgpqi0rgvwa9f";
        }
        {
          name = "project-manager";
          publisher = "alefragnani";
          version = "12.5.0";
          sha256 = "0v2zckwqyl33jwpzjr8i3p3v1xldkindsyip8v7rs1pcmqmpv1dq";
        }
        {
          name = "nix-env-selector";
          publisher = "arrterian";
          version = "1.0.7";
          sha256 = "0mralimyzhyp4x9q98x3ck64ifbjqdp8cxcami7clvdvkmf8hxhf";
        }
        {
          name = "Nix";
          publisher = "bbenoist";
          version = "1.0.1";
          sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
        }
        {
          name = "better-toml";
          publisher = "bungcip";
          version = "0.3.2";
          sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3";
        }
        {
          name = "path-intellisense";
          publisher = "christian-kohler";
          version = "2.8.0";
          sha256 = "04vardis9k6yzaha5hhhv16c3z6np48adih46xj88y83ipvg5z2l";
        }
        {
          name = "gitignore";
          publisher = "codezombiech";
          version = "0.7.0";
          sha256 = "0fm4sxx1cb679vn4v85dw8dfp5x0p74m9p2b56gqkvdap0f2q351";
        }
        {
          name = "bracket-pair-colorizer-2";
          publisher = "CoenraadS";
          version = "0.2.4";
          sha256 = "1vdd3l5khxacwsqnzd9a19h2i7xpp3hi7awgdfbwvvr8w5v8vkmk";
        }
        {
          name = "dart-code";
          publisher = "Dart-Code";
          version = "3.37.20220310";
          sha256 = "07ppxizyawy247n2spz44qna1xsq7irywdkq6w9xsmd6lqbw9xcx";
        }
        {
          name = "flutter";
          publisher = "Dart-Code";
          version = "3.37.20220301";
          sha256 = "0l96nx6xwciq509q0cijkymhyvdhx04al4ypr3k9ydcapajvhb9x";
        }
        {
          name = "wal-theme";
          publisher = "dlasagno";
          version = "1.2.0";
          sha256 = "17130z04jg8hhj1k62q3d3lni10hajrckf1y95bbnm2d57j8spjz";
        }
        {
          name = "gitlens";
          publisher = "eamodio";
          version = "12.0.5";
          sha256 = "0zfawv9nn88x8m30h7ryax0c7p68najl23a51r88a70hqppzxshw";
        }
        {
          name = "tokyo-night";
          publisher = "enkia";
          version = "0.8.4";
          sha256 = "15ab2k0xs8kvws8zq0irch4cvq1dc0zr3xynj0qn78zzbgwq92c7";
        }
        {
          name = "vscode-pull-request-github";
          publisher = "GitHub";
          version = "0.41.2022033109";
          sha256 = "02iqf7pm2ldfw9xwlibl97nywyfkmnvj26y2s9jia1hvhwb6s7ql";
        }
        {
          name = "vscode-env";
          publisher = "IronGeek";
          version = "0.1.0";
          sha256 = "1ygfx1p38dqpk032n3x0591i274a63axh992gn6z1d45ag9bs6ji";
        }
        {
          name = "plantuml";
          publisher = "jebbs";
          version = "2.17.2";
          sha256 = "0yxnfq34g563w96dwfirqscjfclhzr48yb9cwfjjf0c0l638x9vv";
        }
        {
          name = "codeacejumper";
          publisher = "lucax88x";
          version = "3.3.2";
          sha256 = "02a5f0lg0rmrjjf52z30mk19ii71pcdxjmbcb4v6haw1pkm6anqn";
        }
        {
          name = "flutter-tree";
          publisher = "marcelovelasquez";
          version = "1.0.0";
          sha256 = "08glv02b5d5f4jfdfddg62jvdzscinl2jhsb7gpz36rxrbp0f17s";
        }
        {
          name = "git-graph";
          publisher = "mhutchie";
          version = "1.30.0";
          sha256 = "000zhgzijf3h6abhv4p3cz99ykj6489wfn81j0s691prr8q9lxxh";
        }
        {
          name = "remote-ssh";
          publisher = "ms-vscode-remote";
          version = "0.78.0";
          sha256 = "1743rwmbqw2mi2dfy3r9qc6qkn42pjchj5cl8ayqvwwrrrvvvpxx";
        }
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.78.0";
          sha256 = "0vfzz6k4hk7m5r6l7hszbf4fwhxq6hxf8f8gimphkc57v4z376ls";
        }
        {
          name = "awesome-flutter-snippets";
          publisher = "Nash";
          version = "3.0.3";
          sha256 = "1kmklahzzng7fy1xgqmyzphyfpy2dppfbvqwbsw3al2s0psynxd0";
        }
        {
          name = "color-highlight";
          publisher = "naumovs";
          version = "2.5.0";
          sha256 = "0ri1rylg0r9r1kdc67815gjlq5fwnb26xpyziva6a40brrbh70vm";
        }
        {
          name = "material-icon-theme";
          publisher = "PKief";
          version = "4.15.0";
          sha256 = "1bs78k27ypq298zyhclcj3xac9xlj7f3zpy6jh2gv9x8fbwnqp3x";
        }
        {
          name = "gruvbox-material";
          publisher = "sainnhe";
          version = "6.5.0";
          sha256 = "1r9kgwrh6jjp8i6aa07prhrb398d5isf9ics4wmdbvd6k0gnzf8n";
        }
        {
          name = "code-spell-checker";
          publisher = "streetsidesoftware";
          version = "2.1.11";
          sha256 = "0zjvv6msz9w9k81rkynqp6xgfzd11slakmr1rm8v875bpgzdfg9s";
        }
        {
          name = "code-spell-checker-russian";
          publisher = "streetsidesoftware";
          version = "2.0.3";
          sha256 = "1bq478y4g3ibf2hww6mj06m0l2c9s1psxwq7cymh646p4v87ljcg";
        }
        {
          name = "pdf";
          publisher = "tomoki1207";
          version = "1.2.0";
          sha256 = "1bcj546bp0w4yndd0qxwr8grhiwjd1jvf33jgmpm0j96y34vcszz";
        }
        {
          name = "sort-lines";
          publisher = "Tyriar";
          version = "1.9.1";
          sha256 = "0dds99j6awdxb0ipm15g543a5b6f0hr00q9rz961n0zkyawgdlcb";
        }
        {
          name = "vscode-nginx";
          publisher = "william-voyek";
          version = "0.7.2";
          sha256 = "0s4akrhdmrf8qwn6vp8kc31k5hx2k2wml5mcashfc09hxiqsf2cq";
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
