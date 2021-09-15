{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    inputs.home-manager.nixosModules.home-manager

    applications
    # auto-run
    boot
    devices
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
    xdg
    zsh
  ];
}
