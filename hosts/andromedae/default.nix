{
  config,
  pkgs,
  lib,
  inputs,
  flake-self,
  secretsDir,
  ...
}:
let
  inherit (lib) mkForce;
  defaultUser = config.ataraxia.defaults.users.defaultUser;
  hyprPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./samba.nix
    ./noctalia.nix

    inputs.catppuccin.nixosModules.catppuccin
    inputs.lsfg-vk.nixosModules.default
    inputs.corecycler.nixosModules.default
  ];
  catppuccin.enable = true;
  catppuccin.accent = "mauve";
  catppuccin.flavor = "mocha";
  catppuccin.cache.enable = true;

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
    ifname = "enp10s0";
    mac = "10:ff:e0:e1:8d:13";
    bridge.enable = true;
    ipv4 = [
      {
        address = "10.10.10.100/24";
        gateway = "10.10.10.1";
      }
    ];
  };

  boot.binfmt.addEmulatedSystemsToNixSandbox = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Home-manager
  home-manager.users.${defaultUser} = {
    # TODO: remove after migrate to use lua config
    catppuccin.alacritty.enable = false;
    catppuccin.hyprland.enable = false;
    catppuccin.qt5ct.enable = false;
    catppuccin.kvantum.enable = false;
    ataraxia.theme.catppuccin.enable = true;
    # ataraxia.theme.catppuccin.gtk = false;
    ataraxia.wayland.waybar.enable = false;

    ataraxia.defaults.role = "desktop";
    ataraxia.programs.brave.enable = true;
    ataraxia.programs.element-desktop.enable = true;
    ataraxia.programs.emulators.enable = true;
    ataraxia.programs.lmstudio.enable = true;
    ataraxia.programs.mangohud.enable = true;
    ataraxia.programs.nushell.enable = true;
    ataraxia.programs.umu-launcher.enable = true;
    ataraxia.programs.winboat.enable = true;
    ataraxia.programs.zed-editor.enable = true;
    ataraxia.programs.zen-browser.enable = true;
    ataraxia.services.modprobed-db.enable = true;

    # ataraxia.programs.mpvpaper.enable = true;
    # ataraxia.programs.mpvpaper.wallpaper = flake-self + "/wallpaper.mkv";
    ataraxia.programs.shaderbg.enable = true;
    ataraxia.programs.shaderbg.shader = flake-self + "/modules/home/programs/shaderbg/columns.frag";

    wayland.windowManager.hyprland.settings = {
      monitor = mkForce [
        "DP-3,2560x1440@164.998993,0x0,1,bitdepth,10,cm,srgb"
        "HDMI-A-1,1920x1080@60,-1920x360,1"
        ",highres,auto,1"
      ];
      misc.vrr = 0; # TODO: Remove after flickering is fixed
      exec-once = [
        "${pkgs.xrandr}/bin/xrandr --output DP-3 --primary"
      ];
    };

    home.packages = with pkgs; [
      anydesk
      appimage-run
      ccache
      devenv
      dig.dnsutils
      freerdp
      freesmlauncher
      llama-cpp
      lsof
      modprobed-db
      nfs-utils
      nh
      nixd
      nix-diff
      nix-init
      nix-tree
      nix-update
      nix-update-docker-image
      nixfmt
      nixos-anywhere
      protonplus
      radeontop
      rust-analyzer
      rustdesk-flutter
      sqlitebrowser
      sshfs
      winbox4
      via
      zfs-dedup

      kdePackages.ark
      kdePackages.dolphin
      kdePackages.dolphin-plugins

      voidrun
      stalker-gamma-cli
      dotnetCorePackages.dotnet_9.runtime

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
      # packwiz
      # piper
      # streamrip
      # wayvnc
      # winbox
      # yt-archivist
    ];

    home.sessionVariables = {
      WAYLANDDRV_PRIMARY_MONITOR = "DP-3";
    };

    xdg.configFile."uwsm/env".text = ''
      export WAYLANDDRV_PRIMARY_MONITOR="DP-3"
    '';

    persist.state.directories = [
      ".anydesk"
      ".config/image-updater"
      ".config/lsfg-vk"
      ".config/nix-init"
      ".config/obs-studio"
      ".config/rustdesk"
      ".config/sops/age"
      ".config/stalker-gamma"
      ".config/WarThunder"
      ".local/share/corecycler"
      ".local/share/ficsit"
      ".local/share/FreesmLauncher"
      ".local/share/voidrun"
      "nixos-config"
      "projects"

      ".config/Tachibana Labs"
      ".config/SLSsteam"
      ".local/share/ACCELA"
      ".local/share/SLSsteam"
      ".local/share/SteaMidra"
    ];

    home.stateVersion = "25.05";
  };

  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [ pkgs.via ];

  # Services
  hardware.i2c.enable = true;
  services.hardware.openrgb.enable = true;
  services.postgresql.settings = {
    full_page_writes = "off";
    wal_init_zero = "off";
    wal_recycle = "off";
  };
  programs.nix-ld.enable = true;
  programs.obs-studio.enable = true;
  programs.obs-studio.package =
    inputs.ataraxiasjel-builds.packages.${pkgs.stdenv.hostPlatform.system}.obs-studio;

  ataraxia.virtualisation.docker = true;
  ataraxia.virtualisation.libvirt = true;
  ataraxia.virtualisation.podman = true;

  ataraxia.defaults.bluetooth.enable = true;
  ataraxia.programs.lact.enable = true;
  ataraxia.programs.steam.enable = true;
  ataraxia.programs.waydroid.enable = true;
  ataraxia.vpn.sing-box.enable = true;
  ataraxia.vpn.sing-box.config = "ataraxia-singbox";
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
  ataraxia.vpn.amnezia-vpn.enable = true;

  networking.firewall.trustedInterfaces = [
    "virbr-lan"
    "virbr-wan"
  ];

  networking.firewall = {
    allowedTCPPorts = [ 30980 ];
    allowedUDPPorts = [ 30980 ];
  };

  # Mesa from unstable channel
  # hardware.graphics.package = pkgs.mesaUnstable;
  # hardware.graphics.package32 = pkgs.mesaUnstablei686;
  # programs.hyprland.package = pkgs.hyprlandUnstable;
  # programs.hyprland.portalPackage = pkgs.hyprlandPortalUnstable;
  programs.hyprland.package = hyprPkgs.hyprland;
  programs.hyprland.portalPackage = hyprPkgs.xdg-desktop-portal-hyprland;
  services.lsfg-vk.enable = true;
  services.lsfg-vk.ui.enable = true;

  services.corecycler = {
    enable = true;
    deviceAccess = true;
    deviceAccessUser = defaultUser;
    unfreeBackends = true;
    cpuid = true;
    it87 = true;
    ryzenSmu = true;
    spd5118 = true;
    zenpower = true;
  };

  # Test nushell by default
  environment.shells = [ config.home-manager.users.${defaultUser}.programs.nushell.package ];
  users.users.${defaultUser}.shell = mkForce pkgs.bashInteractive;
  programs.bash.interactiveShellInit = ''
    if ! [ "$TERM" = "dumb" ]; then
      exec nu
    fi
  '';

  # Secure boot
  environment.systemPackages = [ pkgs.sbctl ];
  boot.loader.limine.secureBoot.enable = true;
  boot.loader.limine.extraEntries = ''
    /Windows
    //Windows 10
            protocol: efi
            # This tells the efi protocol to call the specified EFI file and load it.
            path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
            comment: Boot Microsoft Windows
  '';

  # Github api token for rate-limiting
  sops.secrets.gh-token-nix.sopsFile = secretsDir + /misc.yaml;
  nix.extraOptions = ''
    !include ${config.sops.secrets.gh-token-nix.path}
  '';

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
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "users"
      ];
    };
  };

  persist.state.directories = [
    "/var/lib/OpenRGB"
    "/var/lib/sbctl"
  ];

  system.stateVersion = "25.05";
}
