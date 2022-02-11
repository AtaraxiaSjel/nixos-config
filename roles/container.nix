{ inputs, pkgs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }

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
    zsh
  ];

  environment.systemPackages = [ pkgs.kitty ];
}