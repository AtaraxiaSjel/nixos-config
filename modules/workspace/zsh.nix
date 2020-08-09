{ pkgs, config, inputs, ... }: {

  environment.pathsToLink = [ "/share/zsh" ];
  environment.sessionVariables.SHELL = "zsh";
  home-manager.users.alukard.programs.zsh = {
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
    shellAliases = {
      "clr" = "clear";
      "weather" = "curl wttr.in/Volzhskiy";
      # "l" = "ls -lah --group-directories-first";
      "rede" = "systemctl --user start redshift.service &";
      "redd" = "systemctl --user stop redshift.service &";
      "bare" = "systemctl --user start barrier-client.service &";
      "bard" = "systemctl --user stop barrier-client.service &";
      "wgup" = "_ systemctl start wg-quick-wg0.service";
      "wgdown" = "_ systemctl stop wg-quick-wg0.service";
      "show-packages" = "_ nix-store -q --references /run/current-system/sw";
      "cat" = "${pkgs.bat}/bin/bat";
      "nsp" = "nix-shell --run zsh -p";
      "find" = "fd";
      "grep" = "rg";
      # "mkdir" = "ad";
      "man" = "pinfo";
      "l" = "exa -lahgF@ --git --group-directories-first";
      "tree" = "exa -T";
      "ltree" = "exa -lhgFT@ --git";
      "atree" = "exa -aT";
      "latree" = "exa -lahgFT@ --git";
    };
    initExtra = ''
      nixify() {
        if [ ! -e ./.envrc ]; then
          wget -O ./.envrc https://raw.githubusercontent.com/kalbasit/nur-packages/master/pkgs/nixify/envrc
          sed -i '$s/use_nix.\+/use_nix/' ./.envrc
          direnv allow
        fi
        if [ ! -e shell.nix ]; then
          cat > shell.nix <<'EOF'
      { pkgs ? import <nixpkgs> {} }:
      pkgs.mkShell {
        # Hack to SSL Cert error
        GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt;
        SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt;
        buildInputs = [];
      }
      EOF
        fi
      }
    '';
  };
}
