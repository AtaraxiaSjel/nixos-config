{ inputs, ... }: {
  imports = with inputs.self.nixosModules; [
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
    security
    ssh
    xdg
    zsh
  ];
}
