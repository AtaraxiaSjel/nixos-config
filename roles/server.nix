{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    inputs.home-manager.nixosModules.home-manager
    inputs.base16.hmModule

    applications
    devices
    git
    gpg
    locale
    misc
    nix
    overlay
    secrets
    secrets-envsubst
    security
    themes
    ssh
    xdg
    zsh

    kitty

    direnv
    fonts
  ];
}
