let
  outputs = builtins.getFlake (toString ./.);
  pkgs = outputs.inputs.nixpkgs;
  host-workstation = pkgs.lib.collect pkgs.lib.isDerivation outputs.packages.x86_64-linux.host-workstation;
  host-hypervisor = pkgs.lib.collect pkgs.lib.isDerivation outputs.packages.x86_64-linux.host-hypervisor;
in host-workstation ++ host-hypervisor
