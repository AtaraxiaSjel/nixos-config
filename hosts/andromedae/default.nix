{
  config,
  pkgs,
  inputs,
  ...
}:
let
  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix

    inputs.catppuccin.nixosModules.catppuccin
  ];
  catppuccin.enable = true;
  catppuccin.accent = "mauve";
  catppuccin.flavor = "mocha";

  ataraxia.defaults.role = "desktop";
  ataraxia.defaults.hardware.cpuVendor = "amd";
  ataraxia.defaults.hardware.gpuVendor = "amd";
  # Impermanence
  ataraxia.filesystems.zfs.enable = true;
  ataraxia.filesystems.zfs.eraseOnBoot.enable = true;
  ataraxia.filesystems.zfs.eraseOnBoot.snapshots = [
    "rpool/nixos/root@empty"
    "rpool/user/home@empty"
  ];
  ataraxia.filesystems.zfs.mountpoints = [
    "/etc/secrets"
    "/media/libvirt"
    "/nix"
    "/persist"
    "/srv"
    "/var/lib/ccache"
    "/var/lib/containers"
    "/var/lib/docker"
    "/var/lib/libvirt"
    "/var/lib/postgresql"
    "/var/log"
    "/vol"
  ];

  ataraxia.networkd = {
    enable = true;
    ifname = "enp8s0";
    mac = "60:45:cb:a0:15:11";
    bridge.enable = true;
    ipv4 = [
      {
        address = "10.10.10.100/24";
        gateway = "10.10.10.1";
        dns = [
          "10.10.10.1"
          "9.9.9.9"
        ];
      }
    ];
  };

  # Home-manager
  home-manager.users.${defaultUser} = {
    ataraxia.defaults.role = "desktop";
    ataraxia.theme.catppuccin.enable = true;
    ataraxia.services.modprobed-db.enable = true;

    wayland.windowManager.hyprland.settings = {
      # TODO: Remove after flickering is fixed
      # misc.vrr = lib.mkForce 0;
      monitor = mkForce [
        "DP-3,2560x1440@164.998993,0x0,1"
        "HDMI-A-1,1920x1080@60,-1920x360,1"
        ",highres,auto,1"
      ];
      exec-once = [
        "${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --primary"
      ];
    };

    home.packages = with pkgs; [
      devenv
      nh
      nix-diff
      nix-update
      nixfmt-rfc-style
      nixos-anywhere

      # anydesk
      # arduino-ide
      # dbeaver-bin
      # dig.dnsutils
      # distrobox
      # exercism
      # freerdp
      # kdePackages.merkuro
      # libsForQt5.ark
      # libsForQt5.dolphin
      # maa-cli
      # mitmproxy
      # mkvtoolnix
      modprobed-db
      # packwiz
      # piper
      # prismlauncher
      # radeontop
      # streamrip
      # wayvnc
      # winbox
      # yt-archivist
    ];

    persist.state.directories = [
      ".config/sops/age"
      "nixos-config"
      "projects"
    ];

    home.stateVersion = "25.05";
  };

  # Services
  services.postgresql.settings = {
    full_page_writes = "off";
    wal_init_zero = "off";
    wal_recycle = "off";
  };
  ataraxia.vpn.sing-box.enable = true;
  ataraxia.vpn.sing-box.config = "ataraxia-singbox";
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Mesa from unstable channel
  hardware.graphics.package = pkgs.mesaUnstable;
  hardware.graphics.package32 = pkgs.mesaUnstablei686;
  programs.hyprland.package = pkgs.hyprlandUnstable;
  programs.hyprland.portalPackage = pkgs.hyprlandPortalUnstable;

  # Auto-mount lan nfs share
  fileSystems = {
    "/media/files" = {
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/15fa11a1-a6d8-4962-9c03-74b209d7c46a";
      options = [
        "nofail"
        "uid=${toString config.users.users.${defaultUser}.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
    "/media/win-sys" = {
      fsType = "ntfs";
      device = "/dev/disk/by-partuuid/4fba33e7-6b47-4e3b-b18b-882a58032673";
      options = [
        "nofail"
        "uid=${toString config.users.users.${defaultUser}.uid}"
        "gid=${toString config.users.groups.users.gid}"
      ];
    };
    "/media/local-nfs" = {
      device = "10.10.10.11:/";
      fsType = "nfs4";
      options = [
        "nfsvers=4.2"
        "x-systemd.automount"
        "noauto"
      ];
    };
  };

  system.stateVersion = "25.05";
}
