{ modulesPath, inputs, lib, pkgs, config, ... }: {
  imports = with inputs.self; [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
    inputs.disko.nixosModules.disko

    ./hardware
    ./network.nix
    ./nix.nix
    ./wireguard.nix

    customModules.devices
    customModules.users

    nixosProfiles.hardened
    nixosProfiles.overlay
  ];

  # disko.devices = import ./disko.nix { inherit lib; };

  # Misc
  boot = {
    # TODO: hardened kernel with bcachefs patches
    supportedFilesystems = [ "vfat" "btrfs" ];
    kernelModules = [ "tcp_bbr" ];
    kernelParams = [
      "scsi_mod.use_blk_mq=1"
      "kvm.ignore_msrs=1"
      "kvm.report_ignored_msrs=0"
    ];
    kernel.sysctl = {
      "vm.swappiness" = 50;
      "vm.vfs_cache_pressure" = 200;
      "vm.dirty_background_ratio" = 1;
      "vm.dirty_ratio" = 40;
      "vm.page-cluster" = 0;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      # "net.core.default_qdisc" = "fq";
    };
    loader.grub = {
      devices = [ "/dev/sda" ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  deviceSpecific.isServer = true;
  services.journald.extraConfig = "Compress=false";
  nix.optimise.automatic = false;
  nix.distributedBuilds = lib.mkForce false;
  hardware.enableRedistributableFirmware = true;
  environment.noXlibs = lib.mkForce false;
  fonts.enableDefaultFonts = lib.mkForce false;
  # fonts.fonts = [ (pkgs.nerdfonts.override { fonts = [ "FiraCode" "VictorMono" ]; }) ];
  security.polkit.enable = true;
  # security.pam.enableSSHAgentAuth = true;
  environment.systemPackages = with pkgs; [
    bat
    bottom
    comma
    git
    kitty
    micro
    nix-index-update
    pwgen
  ];

  # Locale
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LANGUAGE = "en_GB.UTF-8";
    LC_ALL = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
  };
  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    LANGUAGE = "en_GB.UTF-8";
    LC_ALL = "en_GB.UTF-8";
  };

  # Hardened
  networking.firewall = {
    enable = true;
    allowPing = false;
    allowedTCPPorts = lib.mkDefault [ ];
    allowedUDPPorts = lib.mkDefault [ ];
  };
  systemd.coredump.enable = false;
  programs.firejail.enable = true;

  # Users
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = lib.mkForce "no";
    settings.X11Forwarding = false;
    extraConfig = "StreamLocalBindUnlink yes";
    ports = [ 22 ];
  };
  users.mutableUsers = false;
  users.users = {
    ${config.mainuser} = {
      isNormalUser = true;
      extraGroups = [ "disk" "systemd-journal" "wheel" ];
      uid = 1000;
      hashedPassword =
        "$y$j9T$ZC44T3XYOPapB26cyPsA4.$8wlYEbwXFszC9nrg0vafqBZFLMPabXdhnzlT3DhUit6";
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+xd8ClJPvJuAdYC9HlNnjiubEtYfvnKjYr9ROV+UmPVvI3ZITF24OaMI+fxgR0EqGfcUzSGom8528IB53Q3aFMIAaA0vKjW+jrByyB2l/k/+ttpLbH75c9WyOpAcUDTen8BhHKPyXOHoJ1jLu7GFmtPZ+mZo8thFB/VIRrwECHd8DnF0drsSCorkRp1bZC7bAHgztaYHNBUoAVGgJ7nLwW7DotlgbUEDiPJHXOxd/c/ZlXIB/cfUUqF+L5ThbMPhMcwRMspLy+nQdmHhih9k6SkvYqJoNqHT5/XeShb0RkIzvUWT2CYTPop5kAY5mMnatVTOY1FZPhHzk3G8MhOQ3r/elM/ecZxmjL8uozMN9kRGf1IL4DgQZfVqQRILdNSQGb0tfeiyirNZe1RlDw9UvMnZJOw0EkiC9lSSRhBWXXxAmxRrbNFTPQSp+/kiIGDmp2AsGhD11CfTDEU3wcLEUPBUqp1FYSzHncJyEKGy2Dpa5xaUJ0cuyGL4W3WHDXa4sTfY+AIXbQTD88Ujdsbfzyd6lrikG4D/crCurXissrh7q9DuYKWRI24cp5bw9lG33U1EXisnZqFyZNwMAmSj2QEGsHCwSevn0FgyRa2WYXgpZ9hfgY4le+ZSMo2JTosQ6DjGyxMDyQAHJ/ismTTzL67Q2p6U+73toYm62Qqdspw== (none)"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP0/DReYSAfkucroMTdELzTORsGhhbEa+W0FDFBnwViHuoqoKvetCOkW657icexc5v/j6Ghy3+Li9twbHnEDzUJVtNtauhGMjOcUYt6pTbeJ09CGSAh+orxzeY4vXp7ANb91xW8yRn/EE4ALxqbLsc/D7TUMl11fmf0UW+kLgU5TcUYVSLMjQqBpD1Lo7lXLrImloDxe5fwoBDT09E59r9tq6+/3aHz8mpKRLsIQIV0Av00BRJ+/OVmZuBd9WS35rfkpUYmpEVInSJy3G4O6kCvY/zc9Bnh67l4kALZZ0+6W23kBGrzaRfaOtCEcscwfIu+6GXiHOL33rrMNNinF0T2942jGc18feL6P/LZCzqz8bGdFNxT43jAGPeDDcrJEWAJZFO3vVTP65dTRTHQG2KlQMzS7tcif6YUlY2JLJIb61ZfLoShH/ini/tqsGT0Be1f3ndOFt48h4XMW1oIF+EXaHYeO2UJ6855m8Wpxs4bP/jX6vMV38IvvnHy4tWD50= alukard@AMD-Workstation"
      ];
    };
    deploy = {
      description = "The administrator account for the servers.";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys =
        config.users.users.${config.mainuser}.openssh.authorizedKeys.keys;
    };
    root.openssh.authorizedKeys.keys =
      config.users.users.${config.mainuser}.openssh.authorizedKeys.keys;
  };
  # Passwordless sudo for deploy user
  security.sudo.extraRules = [{
    users = [ "deploy" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  system.stateVersion = "23.05";
}
