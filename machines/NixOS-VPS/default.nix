{ modulesPath, inputs, lib, pkgs, config, ... }: {
  imports = with inputs.self; [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/minimal.nix")
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops

    ./disk-config.nix
    ./network.nix
    ./nix.nix
    customModules.devices
    customModules.persist
    customModules.rustic
    customModules.users

    customProfiles.hardened
    ./services/backups.nix
    ./services/dns.nix
    ./services/tailscale.nix
    ./services/tor-bridge.nix
    ./services/wireguard.nix
    ./services/xtls.nix
  ];

  # Impermanence
  boot.initrd = {
    # hardware
    availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    # reset rootfs on reboot
    postDeviceCommands = pkgs.lib.mkBefore ''
      mkdir -p /mnt
      mount -o subvol=/ /dev/sda4 /mnt

      btrfs subvolume list -o /mnt/rootfs |
      cut -f9 -d' ' |
      while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
      done &&

      echo "deleting /root subvolume..."
      btrfs subvolume delete /mnt/rootfs
      echo "restoring blank /root subvolume..."
      btrfs subvolume snapshot /mnt/snapshots/rootfs-blank /mnt/rootfs
      umount /mnt
    '';
  };
  fileSystems."/home".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  persist = {
    enable = true;
    cache.clean.enable = true;
    state = {
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd"
      ];
    };
  };

  # TODO: write all needed modules in boot.kernelModules
  security.lockKernelModules = lib.mkForce false;
  # Misc
  boot = {
    supportedFilesystems = [ "vfat" "btrfs" ];
    kernelModules = [
      "kvm-amd" "tcp_bbr" "veth"
      # podman
      "nft_chain_nat" "xt_addrtype" "xt_comment" "xt_mark" "xt_MASQUERADE"
    ];
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
      # proxy tuning
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.core.default_qdisc" = "cake";
      # "net.core.default_qdisc" = "fq";
      "net.core.rmem_max" = 67108864;
      "net.core.wmem_max" = 67108864;
      "net.core.netdev_max_backlog" = 10000;
      "net.core.somaxconn" = 4096;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 30;
      "net.ipv4.tcp_keepalive_time" = 1200;
      "net.ipv4.tcp_keepalive_probes" = 5;
      "net.ipv4.tcp_keepalive_intvl" = 30;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_max_tw_buckets" = 5000;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_mem" = "25600 51200 102400";
      "net.ipv4.udp_mem" = "25600 51200 102400";
      "net.ipv4.tcp_rmem" = "4096 87380 67108864";
      "net.ipv4.tcp_wmem" = "4096 65536 67108864";
      "net.ipv4.tcp_mtu_probing" = 1;
    };
    loader.grub = {
      enable = true;
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
  environment.noXlibs = lib.mkForce false;
  fonts.enableDefaultPackages = lib.mkForce false;
  security.polkit.enable = true;
  # security.pam.enableSSHAgentAuth = true;
  environment.systemPackages = with pkgs; [
    bat
    bottom
    comma
    git
    kitty
    micro
    pwgen
    inputs.nix-alien.packages.${pkgs.hostPlatform.system}.nix-index-update
    rsync
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
  time.timeZone = "Europe/Helsinki";
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

  # Users
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = lib.mkForce "prohibit-password";
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
  security.sudo = {
    extraRules = [{
      users = [ "deploy" ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];
    extraConfig = ''
      Defaults lecture = never
    '';
  };

  # Podman
  virtualisation = {
    oci-containers.backend = lib.mkForce "podman";
    podman.enable = true;
    podman.dockerSocket.enable = true;
    containers.registries.search = [
      "docker.io" "gcr.io" "quay.io"
    ];
    containers.storage.settings = {
      storage = {
        driver = "overlay";
        graphroot = "/var/lib/podman/storage";
        runroot = "/run/containers/storage";
      };
    };
  };
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];
  security.unprivilegedUsernsClone = true;

  system.stateVersion = "23.11";
  nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";
}
