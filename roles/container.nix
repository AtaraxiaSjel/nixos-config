{ inputs, pkgs, ... }: {
  imports = with inputs.self.customProfiles; [
    inputs.home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }

    git
    gpg
    locale
    misc
    network
    nix
    nnn
    overlay
    ssh
    user
    vlock
    zsh
  ];

  environment.systemPackages = [ pkgs.kitty ];
}
