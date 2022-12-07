{ modulesPath, lib, inputs, pkgs, ... }: {
  imports = with inputs.self; [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
  ];

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
}