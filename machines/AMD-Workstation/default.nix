{ inputs, config, lib, pkgs, ... }: {
  imports = with inputs.self; [
    ./boot.nix
    ./hardware-configuration.nix
    customRoles.workstation

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

    customProfiles.ollama
  ];

  security.pki.certificateFiles = [ ../../misc/mitmproxy-ca-cert.pem ];

  virtualisation.libvirt.guests = {
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
  };

  deviceSpecific.devInfo = {
    cpu.vendor = "amd";
    drive.type = "ssd";
    gpu.vendor = "amd";
    ram = 48;
    fileSystem = "zfs";
  };
  deviceSpecific.isGaming = true;
  deviceSpecific.enableVirtualisation = true;
  # VPN
  deviceSpecific.vpn.tailscale.enable = true;
  sops.secrets.wg-ataraxia.sopsFile = inputs.self.secretsDir + /wg-configs.yaml;
  networking.wg-quick.interfaces.wg0.autostart = false;
  networking.wg-quick.interfaces.wg0.configFile = config.sops.secrets.wg-ataraxia.path;
  # Mount
  # TODO: fix sops
  sops.secrets.files-veracrypt.sopsFile = inputs.self.secretsDir + /amd-workstation/misc.yaml;
  services.cryptmount.files-veracrypt = {
    what = "/dev/disk/by-partuuid/15fa11a1-a6d8-4962-9c03-74b209d7c46a";
    where = "/media/files";
    fsType = "ntfs";
    cryptType = "tcrypt";
    passwordFile = config.sops.secrets.files-veracrypt.path;
    mountOptions = [
      "uid=${toString config.users.users.${config.mainuser}.uid}"
      "gid=${toString config.users.groups.users.gid}"
    ];
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
  };

  powerManagement.cpuFreqGovernor = "schedutil";
  hardware.firmware = [ pkgs.rtl8761b-firmware ];
  services.openssh.settings.PermitRootLogin = lib.mkForce "without-password";
  services.ratbagd.enable = true;
  # Networking
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

  programs.nix-ld.enable = true;
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
      pkgs.mitmproxy
      pkgs.exercism
      pkgs.packwiz
    ];
    xdg.configFile."distrobox/distrobox.conf".text = ''
      container_always_pull="1"
      container_manager="podman"
    '';
    home.stateVersion = "24.05";
  };

  services.netbird.tunnels.wt0.stateDir = "netbird";

  persist.state = {
    directories = [ "/var/lib/netbird" ];
    homeDirectories = [
      ".local/share/winbox"
      ".local/share/PrismLauncher"
      ".local/share/distrobox"
      ".mitmproxy"
      ".config/exercism"
    ];
  };

  system.stateVersion = "23.05";
}
