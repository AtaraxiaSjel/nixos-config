{ inputs, pkgs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }

    applications
    devices
    git
    gpg
    locale
    misc
    nix
    nix-index
    overlay
    secrets
    secrets-envsubst
    security
    ssh
    users
    zsh
  ];

  environment.systemPackages = [ pkgs.kitty ];
}
