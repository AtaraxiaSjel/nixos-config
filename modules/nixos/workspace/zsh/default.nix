{
  config,
  lib,
  pkgs,
  useHomeManager,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.zsh;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.defaults.zsh = {
    enable = mkEnableOption "Default zsh settings";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      eza
      libqalculate
      rsync
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      histFile = "$HOME/.zsh/history";
      histSize = 1000000;
      setOptions = [
        "AUTO_CD"
        "HIST_IGNORE_SPACE"
      ];
      promptInit = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${./p10k.zsh}
      '';
      shellAliases = {
        "_" = "run0";
        "clr" = "clear";
        "rcp" = "rsync -ah --partial --no-whole-file --info=progress2";
        "rrcp" = "_ rsync -ah --partial --no-whole-file --info=progress2";
        "ncg" = "_ nix-collect-garbage";
        "ncgd" = "_ nix-collect-garbage -d";
        "show-packages" = "_ nix-store -q --references /run/current-system/sw";
        "nsp" = "nix-shell --run zsh -p";
        "nd" = "nix develop -c zsh";
        "nb" = "nix build";
        "nr" = "nix run";
        "e" = "$EDITOR";
        "q" = "qalc";
        "man" = "pinfo";
        "l" = "eza -lag";
        "tree" = "eza -T";
        "ltree" = "eza -lgT";
        "atree" = "eza -aT";
        "latree" = "eza -lagT";
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
      interactiveShellInit = ''
        # Familiar line editing without oh-my-zsh: emacs mode + terminfo-driven
        # keys, prefix history search on Up/Down, Ctrl+Left/Right word jump,
        # word kill on Ctrl+Backspace / Ctrl+Delete.
        bindkey -e
        typeset -g -A key
        key[Home]="''${terminfo[khome]}"
        key[End]="''${terminfo[kend]}"
        key[Insert]="''${terminfo[kich1]}"
        key[Backspace]="''${terminfo[kbs]}"
        key[Delete]="''${terminfo[kdch1]}"
        key[Up]="''${terminfo[kcuu1]}"
        key[Down]="''${terminfo[kcud1]}"
        key[Left]="''${terminfo[kcub1]}"
        key[Right]="''${terminfo[kcuf1]}"
        key[Control-Left]="''${terminfo[kLFT5]}"
        key[Control-Right]="''${terminfo[kRIT5]}"
        [[ -n "''${key[Home]}" ]] && bindkey -- "''${key[Home]}" beginning-of-line
        [[ -n "''${key[End]}" ]] && bindkey -- "''${key[End]}" end-of-line
        [[ -n "''${key[Insert]}" ]] && bindkey -- "''${key[Insert]}" overwrite-mode
        [[ -n "''${key[Backspace]}" ]] && bindkey -- "''${key[Backspace]}" backward-delete-char
        [[ -n "''${key[Delete]}" ]] && bindkey -- "''${key[Delete]}" delete-char
        autoload -U up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        [[ -n "''${key[Up]}" ]] && bindkey -- "''${key[Up]}" up-line-or-beginning-search
        [[ -n "''${key[Down]}" ]] && bindkey -- "''${key[Down]}" down-line-or-beginning-search
        # Keep plain arrows working in application cursor mode (then Left is
        # ^[OD, not ^[[D)
        bindkey '^[[A' up-line-or-beginning-search
        bindkey '^[[B' down-line-or-beginning-search
        bindkey '^[OA' up-line-or-beginning-search
        bindkey '^[OB' down-line-or-beginning-search
        bindkey '^[OD' backward-char
        bindkey '^[OC' forward-char
        [[ -n "''${key[Control-Left]}" ]] && bindkey -- "''${key[Control-Left]}" backward-word
        [[ -n "''${key[Control-Right]}" ]] && bindkey -- "''${key[Control-Right]}" forward-word
        # Fallbacks for terminals whose terminfo lacks kLFT5/kRIT5
        bindkey '^[[1;5D' backward-word
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;3D' backward-word
        bindkey '^[[1;3C' forward-word
        # Ctrl+Delete kills word forward; most terminals send Ctrl+Backspace
        # as ^H (same byte as Ctrl+H), kill word backward
        bindkey '^[[3;5~' kill-word
        bindkey '^H' backward-kill-word
        # Shift+Delete, in case the terminal is configured to send it
        # (Shift+Backspace itself is indistinguishable from Backspace here)
        bindkey '^[[3;2~' backward-kill-word

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
      '';
    };

    # TODO: permissions
    persist.state.directories = mkIf (!useHomeManager) [ "/home/${defaultUser}/.zsh" ];

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        persist.state.directories = [ ".zsh" ];
      };
    };

    systemd.tmpfiles.rules = [
      "f /home/${defaultUser}/.zshrc 0644 ${defaultUser} users -"
    ];
  };
}
