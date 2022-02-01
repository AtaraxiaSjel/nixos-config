{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    ./base.nix
    inputs.base16.hmModule

    fonts
    themes

    direnv
    kitty
    nix-index

    coturn
    cloudflare-ddns
    # gitea
    #mailserver
    matrix-synapse
    # nginx
    stubby
    caddy
    vscode-server
  ];
}
