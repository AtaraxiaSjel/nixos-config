{ inputs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }

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
    seadrive
    secrets
    secrets-envsubst
    security
    ssh
    xdg
    zsh
  ];
}
