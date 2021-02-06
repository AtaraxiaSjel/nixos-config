{ inputs, ... }: {
  imports = with inputs.self.nixosModules; [
    inputs.home-manager.nixosModules.home-manager

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
    security
    ssh
    zsh
  ];
}
