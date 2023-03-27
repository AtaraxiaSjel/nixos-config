{ inputs, pkgs, ... }: {
  imports = with inputs.self.nixosProfiles; [
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }

    direnv
    git
    gpg
    hardware
    locale
    misc
    nix
    nix-index
    nnn
    overlay
    pass-secret-service
    ssh
    user
    vlock
    zsh
  ];
}
