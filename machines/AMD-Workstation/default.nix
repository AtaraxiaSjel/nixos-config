{ inputs, config, lib, pkgs, ... }: {
  imports = with inputs.self; [
    ./boot.nix
    ./hardware-configuration.nix
    # ./kernel
    customRoles.workstation

    customProfiles.a2ln-server
    customProfiles.act
    customProfiles.aria2
    # customProfiles.attic
    customProfiles.bluetooth
    customProfiles.cassowary
    customProfiles.emulators
    customProfiles.hoyo
    customProfiles.minecraft
    customProfiles.nicotine
    # customProfiles.sunshine
    customProfiles.wine-games

    customProfiles.ollama
    customProfiles.ccache

    customProfiles.acme
    customProfiles.gitea
    customProfiles.media-stack
    customProfiles.tinyproxy
    ./nginx.nix
    ../Home-Hypervisor/usb-hdd.nix

    # inputs.chaotic.nixosModules.default
  ];

  # chaotic.mesa-git.enable = true;
  # chaotic.mesa-git.fallbackSpecialisation = true;
  # chaotic.mesa-git.method = "GBM_BACKENDS_PATH";

  networking.extraHosts = ''
    127.0.0.1 code.ataraxiadev.com
    127.0.0.1 jackett.ataraxiadev.com
    127.0.0.1 jellyfin.ataraxiadev.com
    127.0.0.1 kavita.ataraxiadev.com
    127.0.0.1 lidarr.ataraxiadev.com
    127.0.0.1 medusa.ataraxiadev.com
    127.0.0.1 qbit.ataraxiadev.com
    127.0.0.1 radarr.ataraxiadev.com
    127.0.0.1 recyclarr.ataraxiadev.com
    127.0.0.1 sonarr.ataraxiadev.com
  '';

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
  networking.firewall.allowedTCPPorts = [ 8000 5900 52736 3456 ];
  networking.nameservers = [ "10.10.10.1" ];
  networking.defaultGateway = "10.10.10.1";
  networking.bridges.br0.interfaces = [ "enp9s0" ];
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "10.10.10.100";
      prefixLength = 24;
    }];
  };

  services.postgresql.settings = {
    full_page_writes = "off";
    wal_init_zero = "off";
    wal_recycle = "off";
  };
  services.modprobed-db.enable = true;

  programs.nix-ld.enable = true;
  home-manager.users.${config.mainuser} = {
    home.packages = [
      inputs.nixos-generators.packages.${pkgs.hostPlatform.system}.nixos-generate
      pkgs.devenv
      pkgs.nh
      pkgs.nix-alien
      pkgs.nix-diff
      pkgs.nix-eval-jobs
      pkgs.nix-fast-build
      # pkgs.nix-init
      pkgs.nix-update
      pkgs.nixfmt-rfc-style
      pkgs.nixos-anywhere
      pkgs.nixpkgs-review

      pkgs.anydesk
      pkgs.arduino-ide
      pkgs.dig.dnsutils
      pkgs.distrobox
      pkgs.exercism
      pkgs.kdePackages.merkuro
      pkgs.libsForQt5.ark
      pkgs.libsForQt5.dolphin
      pkgs.mitmproxy
      pkgs.modprobed-db
      pkgs.packwiz
      pkgs.piper
      pkgs.prismlauncher
      pkgs.radeontop
      pkgs.streamrip
      pkgs.wayvnc
      pkgs.winbox
      pkgs.yt-archivist
    ];
    xdg.configFile."distrobox/distrobox.conf".text = ''
      container_always_pull="1"
      container_manager="podman"
    '';
    home.stateVersion = "24.05";
  };

  services.netbird.clients.priv = {
    interface = "wt0";
    port = 58467;
    hardened = false;
    ui.enable = true;
    autoStart = false;
    config = {
      AdminURL.Host = "net.ataraxiadev.com:443";
      AdminURL.Scheme = "https";
      ManagementURL.Host = "net.ataraxiadev.com:443";
      ManagementURL.Scheme = "https";
      RosenpassEnabled = true;
      RosenpassPermissive = true;
    };
  };

  persist.state = {
    directories = [ "/var/lib/netbird-priv" ];
    homeDirectories = [
      ".arduino15"
      ".arduinoIDE"
      ".local/share/winbox"
      ".local/share/PrismLauncher"
      ".local/share/distrobox"
      ".mitmproxy"
      ".config/exercism"
      ".config/modprobed-db"
      ".config/streamrip"
    ];
  };

  system.stateVersion = "23.05";
}
