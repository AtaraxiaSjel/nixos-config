{
  config,
  pkgs,
  inputs,
  ...
}:
let
  defaultUser = config.ataraxia.defaults.users.defaultUser;
  # hyprPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./disk-config.nix
    ./boot.nix

    inputs.catppuccin.nixosModules.catppuccin
  ];
  catppuccin.enable = true;
  catppuccin.accent = "mauve";
  catppuccin.flavor = "mocha";
  catppuccin.cache.enable = true;

  ataraxia.defaults.role = "laptop";
  ataraxia.defaults.hardware.cpuVendor = "intel";
  ataraxia.defaults.hardware.gpuVendor = "intel";
  ataraxia.defaults.bluetooth.enable = true;
  # Impermanence
  ataraxia.filesystems.zfs.enable = true;
  ataraxia.filesystems.zfs.eraseOnBoot.enable = true;
  ataraxia.filesystems.zfs.eraseOnBoot.snapshots = [
    "rpool/nixos/root@blank"
    "rpool/user/home@blank"
  ];
  ataraxia.filesystems.zfs.mountpoints = [
    "/etc/secrets"
    "/media/libvirt"
    "/nix"
    "/persist"
    "/srv"
    "/var/lib/containers"
    "/var/lib/docker"
    "/var/lib/libvirt"
    "/var/lib/postgresql"
    "/var/log"
  ];

  ataraxia.networkd.enable = false;
  ataraxia.networkmanager.enable = true;

  # Home-manager
  home-manager.users.${defaultUser} = {
    ataraxia.defaults.role = "laptop";
    ataraxia.programs.brave.enable = true;
    ataraxia.programs.mangohud.enable = true;
    ataraxia.programs.nushell.enable = true;
    ataraxia.programs.zen-browser.enable = true;
    ataraxia.services.modprobed-db.enable = true;
    ataraxia.theme.catppuccin.enable = true;
    catppuccin.hyprland.enable = false;

    home.packages = with pkgs; [
      modprobed-db
      sshfs
    ];

    persist.state.directories = [ "projects" ];

    home.stateVersion = "25.05";
  };

  # Services
  services.postgresql.settings = {
    full_page_writes = "off";
    wal_init_zero = "off";
    wal_recycle = "off";
  };
  services.fwupd.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 1;
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
    };
  };

  ataraxia.programs.steam.enable = true;
  ataraxia.vpn.sing-box.enable = true;
  ataraxia.vpn.sing-box.config = "dell-singbox";
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Mesa from unstable channel
  hardware.graphics.package = pkgs.mesaUnstable;
  hardware.graphics.package32 = pkgs.mesaUnstablei686;
  programs.hyprland.package = pkgs.hyprlandUnstable;
  programs.hyprland.portalPackage = pkgs.hyprlandPortalUnstable;
  # programs.hyprland.package = hyprPkgs.hyprland;
  # programs.hyprland.portalPackage = hyprPkgs.xdg-desktop-portal-hyprland;

  # Auto-mount lan nfs share
  fileSystems = {
    "/media/local-nfs" = {
      device = "10.10.10.11:/";
      fsType = "nfs4";
      options = [
        "nfsvers=4.2"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1800"
        "users"
      ];
    };
  };

  system.stateVersion = "25.05";
}
