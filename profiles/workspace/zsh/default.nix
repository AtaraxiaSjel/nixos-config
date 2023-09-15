{ pkgs, config, inputs, ... }: {

  environment.pathsToLink = [ "/share/zsh" ];
  environment.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
  home-manager.users.${config.mainuser} = {
    home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
    home.file.".profile".text = ''
      . "${config.home-manager.users.${config.mainuser}.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
    programs = {
      zsh = {
        enable = true;
        # enableAutosuggestions = true;
        enableCompletion = true;
        oh-my-zsh = {
          enable = true;
          theme = "agnoster";
          plugins = [ "git" "dirhistory" ];
        };
        plugins = [
          {
            name = "zsh-nix-shell";
            file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
            src = pkgs.zsh-nix-shell;
          }
          {
            name = "zsh-autosuggestions";
            file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
            src = pkgs.zsh-autosuggestions;
          }
          {
            name = "you-should-use";
            file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
            src = pkgs.zsh-you-should-use;
          }
          {
            name = "powerlevel10k-config";
            src = ./.;
            file = "p10k.zsh";
          }
          {
            name = "zsh-powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
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
          "_" = "doas";
          "clr" = "clear";
          "rcp" = "${pkgs.rsync}/bin/rsync -ah --partial --no-whole-file --info=progress2";
          "ncg" = "doas nix-collect-garbage";
          "ncgd" = "doas nix-collect-garbage -d";
          "weather" = "curl wttr.in/Volzhskiy";
          "rede" = "systemctl --user start gammastep.service &";
          "redd" = "systemctl --user stop gammastep.service &";
          "show-packages" = "_ nix-store -q --references /run/current-system/sw";
          "nsp" = "nix-shell --run zsh -p";
          "nd" = "nix develop -c zsh";
          "nb" = "nix build";
          "nr" = "nix run";
          "e" = "$EDITOR";
          "q" = "${pkgs.libqalculate}/bin/qalc";
          # "grep" = "${pkgs.ripgrep}/bin/rg";
          "man" = "${pkgs.pinfo}/bin/pinfo";
          "l" = "${pkgs.exa}/bin/exa -lahgF@ --git --group-directories-first";
          "tree" = "${pkgs.exa}/bin/exa -T";
          "ltree" = "${pkgs.exa}/bin/exa -lhgFT@ --git";
          "atree" = "${pkgs.exa}/bin/exa -aT";
          "latree" = "${pkgs.exa}/bin/exa -lahgFT@ --git";
          # "gif2webm" = "(){ ${pkgs.ffmpeg.bin}/bin/ffmpeg -i $1 -c:v libvpx-vp9 -crf 20 -b:v 0 $1.webm ;}";
          "t" = "${pkgs.translate-shell}/bin/trans";
        };
        initExtra = ''
          setopt HIST_IGNORE_SPACE

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
          # zst 7z archive
          z7za() {
            rm /tmp/7z-exclude.lst > /dev/null 2>&1 || true
            for var in "$@"; do
              \find "$var" -type l -print -exec readlink -f {} \; >> /tmp/7z-exclude.lst
            done
            7z a $(basename "$1").7z "$@" -m0=zstd -mx3 -xr@/tmp/7z-exclude.lst
          }
          # zst 7z archive to backup folder
          z7zab() {
            rm /tmp/7z-exclude.lst > /dev/null 2>&1 || true
            for var in "$@"; do
              \find "$var" -type l -print -exec readlink -f {} \; >> /tmp/7z-exclude.lst
            done
            7z a ~/backup/$(basename "$1").7z "$@" -m0=zstd -mx3 -xr@/tmp/7z-exclude.lst
          }

          XDG_DATA_DIRS=$XDG_DATA_DIRS:$GSETTINGS_SCHEMAS_PATH

          PS1="$PS1
          $ "
        '';
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    };
  };

  persist.state.homeDirectories = [ ".local/share/zsh" ];
}
