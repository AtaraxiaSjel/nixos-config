{ pkgs, config, inputs, ... }: {

  environment.pathsToLink = [ "/share/zsh" ];
  environment.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
  home-manager.users.alukard = {
    home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
    programs = {
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
          # {
          #   name = "zsh-nix-shell";
          #   file = "nix-shell.plugin.zsh";
          #   src = inputs.zsh-nix-shell;
          # }
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
          "rede" = "systemctl --user start gammastep.service &";
          "redd" = "systemctl --user stop gammastep.service &";
          "show-packages" = "_ nix-store -q --references /run/current-system/sw";
          "nsp" = "nix-shell --run zsh -p";
          "nd" = "nix develop";
          "nb" = "nix build";
          "nr" = "nix run";
          "e" = "$EDITOR";
          "q" = "qalc";
          # "grep" = "${pkgs.ripgrep}/bin/rg";
          "man" = "${pkgs.pinfo}/bin/pinfo";
          "l" = "exa -lahgF@ --git --group-directories-first";
          "tree" = "exa -T";
          "ltree" = "exa -lhgFT@ --git";
          "atree" = "exa -aT";
          "latree" = "exa -lahgFT@ --git";
          # "gif2webm" = "(){ ${pkgs.ffmpeg.bin}/bin/ffmpeg -i $1 -c:v libvpx-vp9 -crf 20 -b:v 0 $1.webm ;}";
          "hpc" = "bluetoothctl connect D8:37:3B:60:5D:55";
          "hpd" = "bluetoothctl disconnect D8:37:3B:60:5D:55";
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

          XDG_DATA_DIRS=$XDG_DATA_DIRS:$GSETTINGS_SCHEMAS_PATH

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
  };
}
