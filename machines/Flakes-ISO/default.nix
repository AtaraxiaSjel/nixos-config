{ modulesPath, lib, inputs, pkgs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
  ];

  options.device = lib.mkOption { type = lib.types.str; };

  config = {
    environment.systemPackages = [ pkgs.git ];
    nix = {
      nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
      registry.self.flake = inputs.self;
      registry.nixpkgs.flake = inputs.nixpkgs;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
    environment.etc.nixpkgs.source = inputs.nixpkgs;
    environment.etc.self.source = inputs.self;
  };
  # isoImage.volumeID = lib.mkForce "NIXOS_ISO";
}