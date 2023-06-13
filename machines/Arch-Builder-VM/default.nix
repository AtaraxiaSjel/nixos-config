{ inputs, config, lib, pkgs, ... }: {
  imports = with inputs.self; [ ./hardware-configuration.nix ];

  options = {
    device = lib.mkOption { type = lib.types.str; };
    mainuser = lib.mkOption { type = lib.types.str; };
  };

  config = let
    zfs_arc_max = toString (1 * 1024 * 1024 * 1024);
  in {
    networking.wireless.enable = false;
    networking.networkmanager.enable = false;
    networking.hostName = config.device;

    documentation.nixos.enable = lib.mkForce false;
    programs.command-not-found.enable = lib.mkForce false;
    xdg.autostart.enable = lib.mkForce false;
    xdg.icons.enable = lib.mkForce false;
    xdg.mime.enable = lib.mkForce false;
    xdg.sounds.enable = lib.mkForce false;
    services.udisks2.enable = lib.mkForce false;
    nix.optimise.automatic = false;

    fonts.enableDefaultFonts = lib.mkForce false;
    fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" "VictorMono" ]; }) ];

    security.polkit.enable = true;

    boot = {
      kernelParams = [
        "zswap.enabled=0" "quiet" "scsi_mod.use_blk_mq=1"
        "zfs.metaslab_lba_weighting_enabled=0"
        "zfs.zfs_arc_max=${zfs_arc_max}"
      ];
      kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
      cleanTmpDir = true;
      zfs.forceImportAll = false;

      initrd.supportedFilesystems = [ "zfs" ];
      loader = {
        grub = {
          enable = true;
          device = "nodev";
          copyKernels = true;
          efiSupport = true;
          useOSProber = false;
          zfsSupport = true;
        };
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/efi";
        generationsDir.copyKernels = true;
      };

      tmp.useTmpfs = true;
      tmp.tmpfsSize = "16G";
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 150;
    };

    environment.systemPackages = with pkgs; [
      git kitty bat micro bottom nix-index-update pwgen comma
    ];
    nix = {
      nixPath = lib.mkForce [ "self=/etc/self/compat" "nixpkgs=/etc/nixpkgs" ];
      registry.self.flake = inputs.self;
      registry.nixpkgs.flake = inputs.nixpkgs;
      extraOptions = ''
        experimental-features = nix-command flakes
        flake-registry = ${inputs.flake-registry}/flake-registry.json
      '';
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

    security.apparmor.enable = true;
    programs.firejail.enable = true;
    users.mutableUsers = false;
    users.users.${config.mainuser} = {
      isNormalUser = true;
      extraGroups = [
        "docker"
        "kvm"
        "libvirtd"
        "lxd"
        "networkmanager"
        "podman"
        "qemu-libvirtd"
        "systemd-journal"
        "wheel"
      ];
      description = "AtaraxiaDev";
      uid = 1000;
      hashedPassword = "$y$j9T$ZC44T3XYOPapB26cyPsA4.$8wlYEbwXFszC9nrg0vafqBZFLMPabXdhnzlT3DhUit6";
    };
    systemd.services."user@" = { serviceConfig = { Restart = "always"; }; };
    services.getty.autologinUser = config.mainuser;

    users.users.${config.mainuser}.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+xd8ClJPvJuAdYC9HlNnjiubEtYfvnKjYr9ROV+UmPVvI3ZITF24OaMI+fxgR0EqGfcUzSGom8528IB53Q3aFMIAaA0vKjW+jrByyB2l/k/+ttpLbH75c9WyOpAcUDTen8BhHKPyXOHoJ1jLu7GFmtPZ+mZo8thFB/VIRrwECHd8DnF0drsSCorkRp1bZC7bAHgztaYHNBUoAVGgJ7nLwW7DotlgbUEDiPJHXOxd/c/ZlXIB/cfUUqF+L5ThbMPhMcwRMspLy+nQdmHhih9k6SkvYqJoNqHT5/XeShb0RkIzvUWT2CYTPop5kAY5mMnatVTOY1FZPhHzk3G8MhOQ3r/elM/ecZxmjL8uozMN9kRGf1IL4DgQZfVqQRILdNSQGb0tfeiyirNZe1RlDw9UvMnZJOw0EkiC9lSSRhBWXXxAmxRrbNFTPQSp+/kiIGDmp2AsGhD11CfTDEU3wcLEUPBUqp1FYSzHncJyEKGy2Dpa5xaUJ0cuyGL4W3WHDXa4sTfY+AIXbQTD88Ujdsbfzyd6lrikG4D/crCurXissrh7q9DuYKWRI24cp5bw9lG33U1EXisnZqFyZNwMAmSj2QEGsHCwSevn0FgyRa2WYXgpZ9hfgY4le+ZSMo2JTosQ6DjGyxMDyQAHJ/ismTTzL67Q2p6U+73toYm62Qqdspw== (none)"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP0/DReYSAfkucroMTdELzTORsGhhbEa+W0FDFBnwViHuoqoKvetCOkW657icexc5v/j6Ghy3+Li9twbHnEDzUJVtNtauhGMjOcUYt6pTbeJ09CGSAh+orxzeY4vXp7ANb91xW8yRn/EE4ALxqbLsc/D7TUMl11fmf0UW+kLgU5TcUYVSLMjQqBpD1Lo7lXLrImloDxe5fwoBDT09E59r9tq6+/3aHz8mpKRLsIQIV0Av00BRJ+/OVmZuBd9WS35rfkpUYmpEVInSJy3G4O6kCvY/zc9Bnh67l4kALZZ0+6W23kBGrzaRfaOtCEcscwfIu+6GXiHOL33rrMNNinF0T2942jGc18feL6P/LZCzqz8bGdFNxT43jAGPeDDcrJEWAJZFO3vVTP65dTRTHQG2KlQMzS7tcif6YUlY2JLJIb61ZfLoShH/ini/tqsGT0Be1f3ndOFt48h4XMW1oIF+EXaHYeO2UJ6855m8Wpxs4bP/jX6vMV38IvvnHy4tWD50= alukard@AMD-Workstation"
    ];

    users.users.root.openssh.authorizedKeys.keys =
      config.users.users.nixos.openssh.authorizedKeys.keys;

    system.stateVersion = "22.11";
  };
}