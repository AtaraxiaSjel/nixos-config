{ inputs, config, lib, pkgs, ... }: {
  imports = with inputs.self; [
    ./hardware-configuration.nix
    # nixosRoles.base

    customModules.devices
    nixosProfiles.attic
  ];

  options = {
    device = lib.mkOption { type = lib.types.str; };
    mainuser = lib.mkOption { type = lib.types.str; };
  };

  config = {
    networking.hostName = config.device;

    boot = let
      zfs_arc_max = toString (2 * 1024 * 1024 * 1024);
    in {
      initrd.supportedFilesystems = [ "zfs" ];
      loader = {
        grub = {
          enable = true;
          device = "nodev";
          copyKernels = true;
          efiSupport = true;
          enableCryptodisk = true;
          useOSProber = false;
          zfsSupport = true;
          gfxmodeEfi = "2560x1440";
          # efiInstallAsRemovable = true;
          # theme = pkgs.;
        };
        systemd-boot.enable = lib.mkForce false;
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/efi";
        generationsDir.copyKernels = true;
      };

      binfmt.emulatedSystems = [ "aarch64-linux" ];
      kernelPackages = pkgs.linuxPackages_hardened;
      kernelParams = [
        "zfs.metaslab_lba_weighting_enabled=0"
        "zfs.zfs_arc_max=${zfs_arc_max}"
      ];
      tmp.useTmpfs = true;
      tmp.tmpfsSize = "8G";

      zfs.forceImportAll = false;
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
    };

    environment.systemPackages = [ pkgs.git pkgs.kitty ];
    nix = {
      nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
      registry.self.flake = inputs.self;
      registry.nixpkgs.flake = inputs.nixpkgs;
      extraOptions = ''
        experimental-features = nix-command flakes
        flake-registry = ${inputs.flake-registry}/flake-registry.json
      '';
      settings = {
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://nixpkgs-wayland.cachix.org"
          "https://hyprland.cachix.org"
          "https://ataraxiadev-foss.cachix.org"
          "https://cache.ataraxiadev.com/ataraxiadev"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "ataraxiadev-foss.cachix.org-1:ws/jmPRUF5R8TkirnV1b525lP9F/uTBsz2KraV61058="
          "ataraxiadev:V/fCdvz1bMsQzYZcLltcAULST+MoChv53EfedmyJ8Uw="
        ];
        trusted-users = [ "root" config.mainuser "@wheel" ];
      };
    };
    environment.etc.nixpkgs.source = inputs.nixpkgs;
    environment.etc.self.source = inputs.self;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = lib.mkForce "without-password";
      settings.X11Forwarding = false;
      extraConfig = "StreamLocalBindUnlink yes";
      ports = [ 22 ];
    };

    users.mutableUsers = false;
    users.users.ataraxia = {
      isNormalUser = true;
      extraGroups = [ "systemd-journal" "wheel" ];
      uid = 1000;
      hashedPassword = "$y$j9T$ZC44T3XYOPapB26cyPsA4.$8wlYEbwXFszC9nrg0vafqBZFLMPabXdhnzlT3DhUit6";
      shell = pkgs.bash;
    };
    users.users.ataraxia.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+xd8ClJPvJuAdYC9HlNnjiubEtYfvnKjYr9ROV+UmPVvI3ZITF24OaMI+fxgR0EqGfcUzSGom8528IB53Q3aFMIAaA0vKjW+jrByyB2l/k/+ttpLbH75c9WyOpAcUDTen8BhHKPyXOHoJ1jLu7GFmtPZ+mZo8thFB/VIRrwECHd8DnF0drsSCorkRp1bZC7bAHgztaYHNBUoAVGgJ7nLwW7DotlgbUEDiPJHXOxd/c/ZlXIB/cfUUqF+L5ThbMPhMcwRMspLy+nQdmHhih9k6SkvYqJoNqHT5/XeShb0RkIzvUWT2CYTPop5kAY5mMnatVTOY1FZPhHzk3G8MhOQ3r/elM/ecZxmjL8uozMN9kRGf1IL4DgQZfVqQRILdNSQGb0tfeiyirNZe1RlDw9UvMnZJOw0EkiC9lSSRhBWXXxAmxRrbNFTPQSp+/kiIGDmp2AsGhD11CfTDEU3wcLEUPBUqp1FYSzHncJyEKGy2Dpa5xaUJ0cuyGL4W3WHDXa4sTfY+AIXbQTD88Ujdsbfzyd6lrikG4D/crCurXissrh7q9DuYKWRI24cp5bw9lG33U1EXisnZqFyZNwMAmSj2QEGsHCwSevn0FgyRa2WYXgpZ9hfgY4le+ZSMo2JTosQ6DjGyxMDyQAHJ/ismTTzL67Q2p6U+73toYm62Qqdspw== (none)"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP0/DReYSAfkucroMTdELzTORsGhhbEa+W0FDFBnwViHuoqoKvetCOkW657icexc5v/j6Ghy3+Li9twbHnEDzUJVtNtauhGMjOcUYt6pTbeJ09CGSAh+orxzeY4vXp7ANb91xW8yRn/EE4ALxqbLsc/D7TUMl11fmf0UW+kLgU5TcUYVSLMjQqBpD1Lo7lXLrImloDxe5fwoBDT09E59r9tq6+/3aHz8mpKRLsIQIV0Av00BRJ+/OVmZuBd9WS35rfkpUYmpEVInSJy3G4O6kCvY/zc9Bnh67l4kALZZ0+6W23kBGrzaRfaOtCEcscwfIu+6GXiHOL33rrMNNinF0T2942jGc18feL6P/LZCzqz8bGdFNxT43jAGPeDDcrJEWAJZFO3vVTP65dTRTHQG2KlQMzS7tcif6YUlY2JLJIb61ZfLoShH/ini/tqsGT0Be1f3ndOFt48h4XMW1oIF+EXaHYeO2UJ6855m8Wpxs4bP/jX6vMV38IvvnHy4tWD50= alukard@AMD-Workstation"
    ];
    users.users.root.openssh.authorizedKeys.keys =
      config.users.users.ataraxia.openssh.authorizedKeys.keys;

    system.stateVersion = "23.05";
  };
}