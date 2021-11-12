{ pkgs, config, inputs, ... }: {

  environment.pathsToLink = [ "/share/zsh" ];
  environment.sessionVariables.SHELL = "zsh";
  home-manager.users.alukard.programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        plugins = [ "git" "dirhistory" ];
      };
      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = inputs.zsh-nix-shell;
        }
        {
          name = "zsh-autosuggestions";
          src = inputs.zsh-autosuggestions;
        }
        {
          name = "you-should-use";
          src = inputs.zsh-you-should-use;
        }
      ];

      dotDir = ".config/zsh";

      history = rec {
        size = 1000000;
        save = size;
        path = "$HOME/.local/share/zsh/history";
      };

      envExtra = ''
        SHELL="${pkgs.zsh}/bin/zsh";
      '';

      shellAliases = {
        "clr" = "clear";
        "weather" = "curl wttr.in/Volzhskiy";
        # "l" = "ls -lah --group-directories-first";
        "rede" = "systemctl --user start redshift.service &";
        "redd" = "systemctl --user stop redshift.service &";
        "show-packages" = "_ nix-store -q --references /run/current-system/sw";
        # "cat" = "${pkgs.bat}/bin/bat";
        "nsp" = "nix-shell --run zsh -p";
        # "find" = "fd";
        "grep" = "${pkgs.ripgrep}/bin/rg";
        # "mkdir" = "ad";
        "man" = "${pkgs.pinfo}/bin/pinfo";
        "l" = "${pkgs.exa}/bin/exa -lahgF@ --git --group-directories-first";
        "tree" = "${pkgs.exa}/bin/exa -T";
        "ltree" = "${pkgs.exa}/bin/exa -lhgFT@ --git";
        "atree" = "${pkgs.exa}/bin/exa -aT";
        "latree" = "${pkgs.exa}/bin/exa -lahgFT@ --git";
        # "gif2webm" = "(){ ${pkgs.ffmpeg.bin}/bin/ffmpeg -i $1 -c:v libvpx-vp9 -crf 20 -b:v 0 $1.webm ;}";
      };
      initExtra = ''

        nixify() {
          if [ ! -e ./.envrc ]; then
            echo 'use flake' > .envrc
            direnv allow
          fi
          if [ ! -e flake.nix ]; then
            cat > flake.nix <<'EOF'
        {
          description = "shell environment";

          inputs = {
            nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
          };

          outputs = { self, nixpkgs, ... }@inputs: {
            devShell.x86_64-linux = let
              pkgs = import nixpkgs { config.allowUnfree = true; localSystem = "x86_64-linux"; };
            in pkgs.mkShell {
              nativeBuildInputs = [ ];
              buildInputs = with pkgs; [ ];
              shellHook = "";
            };
          };
        }
        EOF
          fi
        }

        rga-fzf() {
          RG_PREFIX="rga --files-with-matches"
          local file
          file="$(
            FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
              fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
                --phony -q "$1" \
                --bind "change:reload:$RG_PREFIX {q}" \
                --preview-window="70%:wrap"
          )" &&
          echo "opening $file" &&
          xdg-open "$file"
        }
        manix-fzf() {
          manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
        }

        source ${pkgs.nix-zsh-completions}/share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh
        fpath=(${pkgs.nix-zsh-completions}/share/zsh/site-functions $fpath)
        autoload -U compinit && compinit
      '';
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
