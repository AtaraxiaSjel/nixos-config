{ inputs, config, lib, pkgs, ... }: {
  imports = with inputs.self; [
    ./boot.nix
    ./hardware-configuration.nix
    nixosRoles.workstation

    # nixosProfiles.stable-diffusion
    nixosProfiles.act
    nixosProfiles.a2ln-server
    nixosProfiles.cassowary
    nixosProfiles.hoyo
    nixosProfiles.sunshine
    nixosProfiles.attic
  ];

  virtualisation.libvirt.guests = {
    win2k22 = {
      autoStart = true;
      user = config.mainuser;
      group = "libvirtd";
      xmlFile = ./vm/win2k22.xml;
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
  deviceSpecific.vpn.mullvad.enable = false;
  deviceSpecific.vpn.ivpn.enable = true;
  # hardware.firmware = [ pkgs.rtl8761b-firmware ];

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

  home-manager.users.${config.mainuser} = {
    home.packages = lib.mkIf config.deviceSpecific.enableVirtualisation [
      inputs.nixos-generators.packages.${pkgs.hostPlatform.system}.nixos-generate
      # pkgs.prismlauncher
      pkgs.piper
      pkgs.osu-lazer-bin
      pkgs.nix-alien
      pkgs.nixpkgs-review
      pkgs.anydesk
      pkgs.winbox
      pkgs.zotero
    ];
    home.stateVersion = "23.05";
  };

  persist.state.homeDirectories = [ ".local/share/winbox" ];

  system.stateVersion = "23.05";

  secrets.wg-ataraxia.services = [ "wg-quick-wg0.service" ];
  networking.wg-quick.interfaces.wg0 = {
    autostart = false;
    configFile = config.secrets.wg-ataraxia.decrypted;
  };
}
