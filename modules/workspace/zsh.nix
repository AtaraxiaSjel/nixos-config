{ pkgs, config, ... }: {

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
        src = pkgs.imports.zsh-nix-shell;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.imports.zsh-autosuggestions;
      }
      {
        name = "you-should-use";
        src = pkgs.imports.zsh-you-should-use;
      }
    ];
    shellAliases = {
      "clr" = "clear";
      "weather" = "curl wttr.in/Volzhskiy";
      "l" = "ls -lah --group-directories-first";
      "rede" = "systemctl --user start redshift.service &";
      "redd" = "systemctl --user stop redshift.service &";
      "bare" = "systemctl --user start barrier-client.service &";
      "bard" = "systemctl --user stop barrier-client.service &";
      "wgup" = "_ systemctl start wg-quick-wg0.service";
      "wgdown" = "_ systemctl stop wg-quick-wg0.service";
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
