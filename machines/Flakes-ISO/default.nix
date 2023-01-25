{ modulesPath, lib, inputs, pkgs, config, ... }: {
  imports = with inputs.self; [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
    ../../modules/autoinstall/default.nix
    ../Home-Hypervisor/autoinstall.nix
  ];

  options = {
    device = lib.mkOption { type = lib.types.str; };
    mainuser = lib.mkOption { type = lib.types.str; };
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

    services.openssh = {
      enable = true;
      passwordAuthentication = true;
      permitRootLogin = "yes";
      forwardX11 = true;
      extraConfig = "StreamLocalBindUnlink yes";
      ports = [ 22 ];
    };

    users.users.nixos.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+xd8ClJPvJuAdYC9HlNnjiubEtYfvnKjYr9ROV+UmPVvI3ZITF24OaMI+fxgR0EqGfcUzSGom8528IB53Q3aFMIAaA0vKjW+jrByyB2l/k/+ttpLbH75c9WyOpAcUDTen8BhHKPyXOHoJ1jLu7GFmtPZ+mZo8thFB/VIRrwECHd8DnF0drsSCorkRp1bZC7bAHgztaYHNBUoAVGgJ7nLwW7DotlgbUEDiPJHXOxd/c/ZlXIB/cfUUqF+L5ThbMPhMcwRMspLy+nQdmHhih9k6SkvYqJoNqHT5/XeShb0RkIzvUWT2CYTPop5kAY5mMnatVTOY1FZPhHzk3G8MhOQ3r/elM/ecZxmjL8uozMN9kRGf1IL4DgQZfVqQRILdNSQGb0tfeiyirNZe1RlDw9UvMnZJOw0EkiC9lSSRhBWXXxAmxRrbNFTPQSp+/kiIGDmp2AsGhD11CfTDEU3wcLEUPBUqp1FYSzHncJyEKGy2Dpa5xaUJ0cuyGL4W3WHDXa4sTfY+AIXbQTD88Ujdsbfzyd6lrikG4D/crCurXissrh7q9DuYKWRI24cp5bw9lG33U1EXisnZqFyZNwMAmSj2QEGsHCwSevn0FgyRa2WYXgpZ9hfgY4le+ZSMo2JTosQ6DjGyxMDyQAHJ/ismTTzL67Q2p6U+73toYm62Qqdspw== (none)"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP0/DReYSAfkucroMTdELzTORsGhhbEa+W0FDFBnwViHuoqoKvetCOkW657icexc5v/j6Ghy3+Li9twbHnEDzUJVtNtauhGMjOcUYt6pTbeJ09CGSAh+orxzeY4vXp7ANb91xW8yRn/EE4ALxqbLsc/D7TUMl11fmf0UW+kLgU5TcUYVSLMjQqBpD1Lo7lXLrImloDxe5fwoBDT09E59r9tq6+/3aHz8mpKRLsIQIV0Av00BRJ+/OVmZuBd9WS35rfkpUYmpEVInSJy3G4O6kCvY/zc9Bnh67l4kALZZ0+6W23kBGrzaRfaOtCEcscwfIu+6GXiHOL33rrMNNinF0T2942jGc18feL6P/LZCzqz8bGdFNxT43jAGPeDDcrJEWAJZFO3vVTP65dTRTHQG2KlQMzS7tcif6YUlY2JLJIb61ZfLoShH/ini/tqsGT0Be1f3ndOFt48h4XMW1oIF+EXaHYeO2UJ6855m8Wpxs4bP/jX6vMV38IvvnHy4tWD50= alukard@AMD-Workstation"
    ];

    # isoImage.contents = [{
    #   source = ../..;
    #   target = "/home/nixos/nixos-config";
    # }];
  };
}