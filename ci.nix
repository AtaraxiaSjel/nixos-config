let
  outputs = builtins.getFlake (toString ./.);
  system = "x86_64-linux";
  pkgs = import outputs.inputs.nixpkgs { inherit system; };
  host-workstation = (pkgs.callPackage ./scripts/force_cached.nix {}) outputs.packages.x86_64-linux.host-workstation;
  host-hypervisor = (pkgs.callPackage ./scripts/force_cached.nix {}) outputs.packages.x86_64-linux.host-hypervisor;
in host-workstation // host-hypervisor
