{ modulesPath, lib, inputs, pkgs, ... }: {
  imports = with inputs.self; [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
  ];

  options = {
    device = lib.mkOption { type = lib.types.str; };
  };

  config = {
    networking.hostName = "Flakes-ISO";

    programs.ssh.extraConfig = ''
      Host nix-builder
        hostname 192.168.0.100
        user ${config.mainuser}
        identitiesOnly yes
        identityFile /home/nixos/ssh-builder
    '';

    environment.systemPackages = [ pkgs.git ];
    nix = {
      nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
      registry.self.flake = inputs.self;
      registry.nixpkgs.flake = inputs.nixpkgs;
      extraOptions = ''
        builders-use-substitutes = true
        experimental-features = nix-command flakes
        flake-registry = ${inputs.flake-registry}/flake-registry.json
      '';
      buildMachines = [{
        hostName = "nix-builder";
        maxJobs = 8;
        sshUser = config.mainuser;
        sshKey = "/home/nixos/ssh-builder";
        systems = [ "x86_64-linux" "i686-linux" ];
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }];
      distributedBuilds = true;
    };
    environment.etc.nixpkgs.source = inputs.nixpkgs;
    environment.etc.self.source = inputs.self;
  };
}