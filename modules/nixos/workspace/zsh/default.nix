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
        "_" = "doas";
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
