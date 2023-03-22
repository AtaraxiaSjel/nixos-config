{ inputs, pkgs, ... }: {
  imports = with inputs.self.customModules; with inputs.self.nixosProfiles; [
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }

    applications
    devices
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
    persist
    secrets
    secrets-envsubst
    security
    ssh
    users
    zsh
  ];

  environment.systemPackages = [ pkgs.kitty ];
}
