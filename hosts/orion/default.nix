{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) concatLists unique recursiveUpdate;
  nginx = config.ataraxia.services.nginx;
in
{
  imports = [
    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-terminfo

    ./boot.nix
    ./disk-config.nix
    ./backups.nix
  ];

  ataraxia.defaults.role = "server";
  ataraxia.defaults.hardware.cpuVendor = "intel";
  ataraxia.defaults.hardware.gpuVendor = "intel";
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
    "/var/lib/containers"
    "/etc/secrets"
    "/var/lib/docker"
    "/var/lib/libvirt"
    "/var/lib/nixos-containers"
    "/var/lib/postgresql"
    "/var/log"
    "/vol"
  ];

  ataraxia.networkd = {
    enable = true;
    domain = "home.ataraxiadev.com";
    ifname = "enp2s0";
    mac = "d4:3d:7e:26:a8:af";
    bridge.enable = true;
    ipv4 = [
      {
        address = "10.10.10.10/24";
        gateway = "10.10.10.1";
      }
    ];
  };

  security.lockKernelModules = lib.mkForce false;
  environment.memoryAllocator.provider = lib.mkForce "libc";

  # Services
  services.postgresql.enable = true;
  services.postgresql.settings = {
    full_page_writes = "off";
    wal_init_zero = "off";
    wal_recycle = "off";
  };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };

  # Auto-mount lan nfs share
  fileSystems."/media/local-nfs" = {
    device = "10.10.10.11:/";
    fsType = "nfs4";
    options = [
      "nfsvers=4.2"
      "x-systemd.automount"
      "noauto"
    ];
  };

  environment.systemPackages = with pkgs; [
    bat
    bottom
    dnsutils
    fd
    kitty.terminfo
    micro
    mkvtoolnix-cli
    nfs-utils
    p7zip
    pwgen
    ripgrep
    rsync
    rustic-rs
    smartmontools
  ];

  ataraxia.services.nginx.enable = true;
  ataraxia.services.nginx.defaultSettings = {
    useACMEHost = "ataraxiadev.com";
    enableACME = false;
    forceSSL = true;
  };

  ataraxia.containers.filestash.enable = true;
  ataraxia.containers.media-stack.enable = true;
  ataraxia.containers.sing-box-filter.enable = true;
  ataraxia.containers.tinyproxy.enable = true;
  ataraxia.containers.tor.enable = true;
  ataraxia.security.acme.enable = true;
  ataraxia.services.authentik.enable = true;
  ataraxia.services.gitea.enable = true;
  ataraxia.services.ntfy-sh.enable = true;
  ataraxia.services.rustdesk.enable = true;
  ataraxia.services.syncyomi.enable = true;
  ataraxia.services.vaultwarden.enable = true;
  ataraxia.services.headscale.enable = true;
  ataraxia.services.headscale.extraDns = unique (
    concatLists (
      map
        (name: [
          {
            inherit name;
            type = "A";
            value = "100.64.0.1";
          }
          {
            inherit name;
            type = "AAAA";
            value = "fd7a:115c:a1e0::1";
          }
        ])
        [
          "api.ataraxiadev.com"
          "cache.ataraxiadev.com"
          "cal.ataraxiadev.com"
          "code.ataraxiadev.com"
          "docs.ataraxiadev.com"
          "element.ataraxiadev.com"
          "files.ataraxiadev.com"
          "home.ataraxiadev.com"
          "jackett.ataraxiadev.com"
          "jellyfin.ataraxiadev.com"
          "kavita.ataraxiadev.com"
          "ldap.ataraxiadev.com"
          "lib.ataraxiadev.com"
          "matrix.ataraxiadev.com"
          "medusa.ataraxiadev.com"
          "pdf.ataraxiadev.com"
          "qbit.ataraxiadev.com"
          "radarr.ataraxiadev.com"
          "restic.ataraxiadev.com"
          "s3.ataraxiadev.com"
          "sonarr.ataraxiadev.com"
          "tools.ataraxiadev.com"
          "turn.ataraxiadev.com"
          "vw.ataraxiadev.com"
          "wiki.ataraxiadev.com"
        ]
    )
  );

  services.nginx.virtualHosts = {
    "incus.ataraxiadev.com" = recursiveUpdate nginx.defaultSettings {
      locations."/" = {
        proxyPass = "https://10.10.10.5:8443";
        proxyWebsockets = true;
      };
    };
  };

  ataraxia.virtualisation.guests = {
    omv = {
      autoStart = true;
      user = "root";
      group = "root";
      xmlFile = ./vm/omv.xml;
    };
  };

  networking.firewall.allowedTCPPorts = [ 9050 ];

  system.stateVersion = "25.05";
}
