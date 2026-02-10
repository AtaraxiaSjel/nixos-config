{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.nushell;
in
{
  options.ataraxia.programs.nushell = {
    enable = mkEnableOption "Enable nushell program";
  };

  config = mkIf cfg.enable {
    programs = {
      carapace.enable = true;
      starship = {
        enable = true;
        settings = {
          add_newline = true;
          ignore_timeout = true;
        };
      };

      nushell = {
        enable = true;
        package = pkgs.nushell;
        # plugins = with pkgs; [];
        extraConfig = ''
          # alias the built in ls command so we don't shadow it
          alias ls-builtin = ls

          # List the filenames, sizes, and modification times of items in a directory.
          @category filesystem
          @search-terms dir
          @example "List the files in the current directory" { ls }
          @example "List visible files in a subdirectory" { ls subdir }
          @example "List visible files with full path in the parent directory" { ls -f .. }
          @example "List Rust files" { ls *.rs }
          @example "List files and directories whose name do not contain 'bar'" { ls | where name !~ bar }
          @example "List the full path of all dirs in your home directory" { ls -a ~ | where type == dir }
          @example "List only the names (not paths) of all dirs in your home directory which have not been modified in 7 days" { ls -as ~ | where type == dir and modified < ((date now) - 7day) }
          @example "Recursively list all files and subdirectories under the current directory using a glob pattern" { ls -a **/* }
          @example "Recursively list *.rs and *.toml files using the glob command" { ls ...(glob **/*.{rs,toml}) }
          @example "List given paths and show directories themselves" { ['/path/to/directory' '/path/to/file'] | each {|| ls -D $in } | flatten }
          def ls [
              --all (-a),         # Show hidden files
              --long (-l),        # Get all available columns for each entry (slower; columns are platform-dependent)
              --short-names (-s), # Only print the file names, and not the path
              --full-paths (-f),  # display paths as absolute paths
              --du (-d),          # Display the apparent directory size ("disk usage") in place of the directory metadata size
              --directory (-D),   # List the specified directory itself instead of its contents
              --mime-type (-m),   # Show mime-type in type column instead of 'file' (based on filenames only; files' contents are not examined)
              --threads (-t),     # Use multiple threads to list contents. Output will be non-deterministic.
              ...pattern: glob,   # The glob pattern to use.
          ]: [ nothing -> table ] {
              let pattern = if ($pattern | is-empty) { [ '.' ] } else { $pattern }
              (ls-builtin
                  --all=$all
                  --long=$long
                  --short-names=$short_names
                  --full-paths=$full_paths
                  --du=$du
                  --directory=$directory
                  --mime-type=$mime_type
                  --threads=$threads
                  ...$pattern
              ) | sort-by type name -i
          }

          def --wrapped ssh [...args] {
            with-env { TERM: "xterm-256color" } {
              ^ssh ...$args
            }
          }

          # Completions
          # carapce completions
          let carapace_completer = {|spans: list<string>|
              carapace $spans.0 nushell ...$spans
              | from json
              | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
          }
          # some completions are only available through a bridge
          # https://carapace-sh.github.io/carapace-bin/setup.html#nushell
          $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

          # fish completions https://www.nushell.sh/cookbook/external_completers.html#fish-completer
          let fish_completer = {|spans|
              ${lib.getExe pkgs.fish} --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
              | from tsv --flexible --noheaders --no-infer
              | rename value description
              | update value {|row|
                let value = $row.value
                let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
                if ($need_quote and ($value | path exists)) {
                  let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
                  $'"($expanded_path | str replace --all "\"" "\\\"")"'
                } else {$value}
              }
          }

          # multiple completions
          # the default will be carapace
          let external_completer = {|spans|
              let expanded_alias = scope aliases
              | where name == $spans.0
              | get -o 0.expansion

              let spans = if $expanded_alias != null {
                  $spans
                  | skip 1
                  | prepend ($expanded_alias | split row ' ' | take 1)
              } else {
                  $spans
              }

              match $spans.0 {
                  # carapace completions are incorrect for nu
                  nu => $fish_completer
                  # fish completes commits and branch names in a nicer way
                  git => $fish_completer
                  # carapace doesn't have completions for asdf
                  asdf => $fish_completer
                  _ => $carapace_completer
              } | do $in $spans
          }
          $env.config = ($env.config? | default {})
          $env.completions.external.enable = true
          $env.completions.external.completer = $external_completer
          $env.config.hooks.command_not_found = source ${config.programs.nix-index.package}/etc/profile.d/command-not-found.nu

          use ${inputs.nushell-scripts}/aliases/bat/bat-aliases.nu *
          use ${inputs.nushell-scripts}/aliases/git/git-aliases.nu *
        '';
        settings = {
          show_banner = false;
          completions = {
            case_sensitive = false;
            quick = true;
            partial = true;
            algorithm = "fuzzy";
          };
          history = {
            file_format = "sqlite";
            max_size = 1000000;
            isolation = true;
          };
        };
        shellAliases = {
          "l" = "ls -a";
          "ll" = "ls -la";
          "_" = "doas";
          "clr" = "clear";
          "rcp" = "rsync -ah --partial --no-whole-file --info=progress2";
          "rrcp" = "_ rsync -ah --partial --no-whole-file --info=progress2";
          "ncg" = "_ nix-collect-garbage";
          "ncgd" = "_ nix-collect-garbage -d";
          "weather" = "curl wttr.in/Volzhskiy";
          "rede" = "systemctl --user start gammastep.service &";
          "redd" = "systemctl --user stop gammastep.service &";
          "show-packages" = "_ nix-store -q --references /run/current-system/sw";
          # "ns" = "nix shell nixpkgs#";
          "nsp" = "nix-shell --run zsh -p";
          "nd" = "nix develop -c zsh";
          "nb" = "nix build";
          "nbf" = "nix-fast-build --flake";
          "nbfc" = "nix-fast-build --skip-cached --flake";
          "nr" = "nix run";
          # "e" = "$EDITOR";
          "q" = "qalc";
          "man" = "pinfo";
          "t" = "trans";
          "steam-gamescope" = "gamescope -b --steam -- steam -pipewire-dmabuf";
          # systemd
          "ctl" = "systemctl";
          "ctlsp" = "systemctl stop";
          "ctlst" = "systemctl start";
          "ctlrt" = "systemctl restart";
          "ctls" = "systemctl status";
          "ctlu" = "systemctl --user";
          "ctlusp" = "systemctl --user stop";
          "ctlust" = "systemctl --user start";
          "ctlurt" = "systemctl --user restart";
          "ctlus" = "systemctl --user status";
          "ctlfailed" = "systemctl --failed --all";
          "ctlrf" = "systemctl reset-failed";
          "ctldrd" = "systemctl daemon-reload";
          "j" = "journalctl";
          "ju" = "journalctl -xe -u";
          "juu" = "journalctl -xe --user-unit";
        };
      };
    };

    persist.state.directories = [
      ".config/nushell"
      ".local/share/nushell"
    ];
  };

}
