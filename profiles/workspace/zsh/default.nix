{ pkgs, config, ... }: {

  environment.pathsToLink = [ "/share/zsh" ];
  environment.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
  home-manager.users.${config.mainuser} = { config, ... }: {
    home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";
    home.file.".profile".text = ''
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
    programs = {
      zsh = {
        enable = true;
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
          {
            name = "zsh-z";
            src = pkgs.zsh-z;
            file = "share/zsh-z/zsh-z.plugin.zsh";
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
          ZSHZ_DATA="$HOME/.local/share/zsh/z";
        '';

        shellAliases = {
          "_" = "doas";
          "clr" = "clear";
          "rcp" = "${pkgs.rsync}/bin/rsync -ah --partial --no-whole-file --info=progress2";
          "rrcp" = "_ ${pkgs.rsync}/bin/rsync -ah --partial --no-whole-file --info=progress2";
          "ncg" = "_ nix-collect-garbage";
          "ncgd" = "_ nix-collect-garbage -d";
          "weather" = "curl wttr.in/Volzhskiy";
          "rede" = "systemctl --user start gammastep.service &";
          "redd" = "systemctl --user stop gammastep.service &";
          "show-packages" = "_ nix-store -q --references /run/current-system/sw";
          "nsp" = "nix-shell --run zsh -p";
          "nd" = "nix develop -c zsh";
          "nb" = "nix build";
          "nbf" = "nix-fast-build --flake";
          "nbfc" = "nix-fast-build --skip-cached --flake";
          "nr" = "nix run";
          "e" = "$EDITOR";
          "q" = "${pkgs.libqalculate}/bin/qalc";
          "man" = "${pkgs.pinfo}/bin/pinfo";
          "l" = "${pkgs.eza}/bin/eza -lahgF --git --group-directories-first";
          "tree" = "${pkgs.eza}/bin/eza -T";
          "ltree" = "${pkgs.eza}/bin/eza -lhgTF --git";
          "atree" = "${pkgs.eza}/bin/eza -aT";
          "latree" = "${pkgs.eza}/bin/eza -lahgTF --git";
          "t" = "${pkgs.translate-shell}/bin/trans";
          "steam-gamescope" = "gamescope -b --steam -- steam -pipewire-dmabuf";
          # systemctl
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
          gif2webm() {
            file="$1"
            dir=$(dirname $1)
            file="$(basename $file)"
            file="''${file%.*}"
            ffmpeg -i "$1" -c:v libvpx-vp9 -b:v 0 -crf 30 -an "$dir/$file.webm"
          }
          gh_delete_runs() {
            org="$1"
            repo="$2"
            set -a
            source /run/secrets/github-token
            set +a
            run_ids=($(${pkgs.gh}/bin/gh api repos/$org/$repo/actions/runs --paginate --jq '.workflow_runs[] | .id'))
            for run_id in "''${run_ids[@]}"
            do
              echo "Deleting Run ID $run_id"
              ${pkgs.gh}/bin/gh api repos/$org/$repo/actions/runs/$run_id --method DELETE >/dev/null &
            done
          }
          jl() {
            journalctl -o json --output-fields=MESSAGE,PRIORITY,_PID,SYSLOG_IDENTIFIER,_SYSTEMD_UNIT "$@" | lnav
          }
          # Start and then view status of service
          ctlsts () {
            systemctl start "$1"
            systemctl status "$1"
          }
          ctlusts () {
            systemctl --user start "$1"
            systemctl --user status "$1"
          }
          # Restart and then view status of service
          ctlrts () {
            systemctl restart "$1"
            systemctl status "$1"
          }
          ctlurts () {
            systemctl --user restart "$1"
            systemctl --user status "$1"
          }

          XDG_DATA_DIRS=$XDG_DATA_DIRS:$GSETTINGS_SCHEMAS_PATH
          export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share

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
