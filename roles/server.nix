{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    inputs.home-manager.nixosModules.home-manager
    inputs.base16.hmModule

    applications
    devices
    fonts
    git
    gpg
    locale
    misc
    network
    nix
    overlay
    secrets
    secrets-envsubst
    security
    ssh
    themes
    xdg
    zsh

    direnv
    kitty

    matrix-synapse
    nginx
  ];
}
