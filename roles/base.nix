{ inputs, ... }: {
  imports = with inputs.self.customProfiles; [
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }

    boot
    git
    gpg
    locale
    misc
    network
    nix
    nnn
    overlay
    user
    ssh
    vlock
    zsh
  ];
}
