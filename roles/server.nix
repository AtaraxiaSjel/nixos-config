{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    ./base.nix
    inputs.base16.hmModule

    fonts
    themes

    direnv
    kitty

    coturn
    gitea
    mailserver
    matrix-synapse
    nginx
    vscode-server
  ];
}
