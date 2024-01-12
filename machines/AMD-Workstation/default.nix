{ inputs, config, lib, pkgs, ... }: {
  imports = with inputs.self; [
    ./boot.nix
    ./hardware-configuration.nix
    customRoles.workstation

    # customProfiles.stable-diffusion
    customProfiles.a2ln-server
    customProfiles.act
    customProfiles.attic
    customProfiles.bluetooth
    customProfiles.cassowary
    customProfiles.emulators
    customProfiles.hoyo
    customProfiles.minecraft
    customProfiles.nicotine
    customProfiles.sunshine
    customProfiles.wine-games
  ];

  security.pki.certificateFiles = [ ../../misc/mitmproxy-ca-cert.pem ];

  virtualisation.libvirt.guests = {
    win2k22 = {
      autoStart = false;
      user = config.mainuser;
      group = "libvirtd";
      xmlFile = ./vm/win2k22.xml;
    };
    win10 = {
      autoStart = true;
      user = config.mainuser;
      group = "libvirtd";
      xmlFile = ./vm/win10.xml;
    };
    win10-server = {
      autoStart = false;
      user = config.mainuser;
      group = "libvirtd";
      xmlFile = ./vm/win10-server.xml;
    };
    fedora-build = {
      autoStart = false;
      user = config.mainuser;
      group = "libvirtd";
      uefi = true;
      memory = 32 * 1024;
      sharedMemory = true;
      cpu = { cores = 6; threads = 2; };
      devices = {
        disks = [
          { diskFile = "/media/libvirt/images/fedora-build.qcow2"; targetName = "vda"; }
          { diskFile = "/media/libvirt/images/android-zfs.qcow2"; targetName = "sda"; bus = "scsi"; }
        ];
        network.macAddress = "52:54:00:f7:be:ef";
      };
    };
  };

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "amd";
      clock = 3700;
      cores = 12;
    };
    drive = {
      type = "ssd";
      speed = 6000;
      size = 1000;
    };
    gpu = {
      vendor = "amd";
    };
    bigScreen = true;
    ram = 48;
    fileSystem = "zfs";
  };
  deviceSpecific.isHost = true;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = true;
  deviceSpecific.enableVirtualisation = true;
  # VPN
  deviceSpecific.vpn.tailscale.enable = true;
  secrets.wg-ataraxia.services = [ "wg-quick-wg0.service" ];
  networking.wg-quick.interfaces.wg0.autostart = false;
  networking.wg-quick.interfaces.wg0.configFile = config.secrets.wg-ataraxia.decrypted;

  hardware.firmware = [ pkgs.rtl8761b-firmware ];
  programs.nix-ld.enable = true;

  secrets.files-veracrypt = { };
  environment.etc.crypttab = {
    text = ''
      files-veracrypt /dev/disk/by-partuuid/15fa11a1-a6d8-4962-9c03-74b209d7c46a /var/secrets/files-veracrypt tcrypt-veracrypt
    '';
  };

  fileSystems = {
    "/media/win-sys" = {
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/5b47cea7-465c-4051-a6ba-76d0eaf42929";
      options = [
        "nofail"
        "uid=${toString config.users.users.${config.mainuser}.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
    "/media/files" = {
      fsType = "ntfs";
      device = "/dev/mapper/files-veracrypt";
      options = [
        "nofail"
        "uid=${toString config.users.users.${config.mainuser}.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  services.openssh.settings.PermitRootLogin = lib.mkForce "without-password";
  services.ratbagd.enable = true;

  networking.firewall.allowedTCPPorts = [ 8000 5900 52736 ];
  networking.nameservers = [ "192.168.0.1" ];
  networking.defaultGateway = "192.168.0.1";
  networking.bridges.br0.interfaces = [ "enp9s0" ];
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.0.100";
      prefixLength = 24;
    }];
  };

  home-manager.users.${config.mainuser} = {
    home.packages = [
      inputs.nixos-generators.packages.${pkgs.hostPlatform.system}.nixos-generate
      pkgs.prismlauncher
      pkgs.piper
      pkgs.nix-alien
      # pkgs.nix-init
      pkgs.nixpkgs-review
      pkgs.anydesk
      pkgs.winbox
      pkgs.devenv
      pkgs.radeontop
      pkgs.wayvnc
      pkgs.distrobox
      pkgs.nix-fast-build
    ];
    xdg.configFile."distrobox/distrobox.conf".text = ''
      container_always_pull="1"
      container_manager="podman"
    '';
    home.stateVersion = "23.05";
  };

  persist.state.homeDirectories = [
    ".local/share/winbox"
    ".local/share/PrismLauncher"
    ".local/share/distrobox"
  ];

  system.stateVersion = "23.05";
}
