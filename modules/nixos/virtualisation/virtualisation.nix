{
  config,
  lib,
  pkgs,
  useHomeManager,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkEnableOption
    mkIf
    optionals
    ;
  cfg = config.ataraxia.virtualisation;

  defaultUser = config.ataraxia.defaults.users.defaultUser;
in
{
  options.ataraxia.virtualisation = {
    docker = mkEnableOption "Enable docker";
    libvirt = mkEnableOption "Enable libvirt";
    podman = mkEnableOption "Enable podman";
  };

  config = mkIf (cfg.docker || cfg.libvirt || cfg.podman) {
    virtualisation = {
      oci-containers.backend = if (!cfg.podman && cfg.docker) then "docker" else "podman";
      docker = {
        enable = cfg.docker;
        daemon.settings = {
          features = {
            buildkit = true;
          };
        };
        storageDriver = "overlay2";
      };
      podman = {
        enable = cfg.podman;
        defaultNetwork.settings.dns_enabled = true;
        dockerSocket.enable = !config.virtualisation.docker.enable;
      };
      containers.containersConf.settings = {
        network = {
          dns_servers = [
            "10.10.10.1"
            "host"
          ];
        };
      };
      containers.registries.search = [
        "docker.io"
        "ghcr.io"
        "quay.io"
      ];
      containers.storage.settings = {
        storage = {
          driver = "overlay";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
      libvirtd = {
        enable = cfg.libvirt;
        qemu = {
          ovmf.enable = true;
          ovmf.packages = [
            (pkgs.OVMFFull.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
          runAsRoot = false;
          swtpm.enable = true;
        };
        onBoot = "ignore";
        onShutdown = "shutdown";
      };

      spiceUSBRedirection.enable = cfg.libvirt;

      quadlet = {
        enable = cfg.podman;
        autoEscape = true;
        autoUpdate.enable = false;
        networks = {
          br-services.networkConfig = {
            disableDns = false;
            dns = [ "10.10.10.1" ];
            driver = "bridge";
            ipamDriver = "host-local";
            ipv6 = false;
            name = "br-services";
            podmanArgs = [ "--interface-name=br-services" ];
            subnets = [ "10.99.0.0/16" ];
          };
        };
      };
    };

    boot.enableContainers = true;

    environment.systemPackages =
      [ ]
      ++ optionals cfg.docker [ pkgs.docker-compose ]
      ++ optionals cfg.libvirt [ pkgs.virtiofsd ]
      ++ optionals cfg.podman [ pkgs.podman-compose ];

    users.users."qemu-libvirtd" = mkIf cfg.libvirt {
      extraGroups = lib.optionals (!config.virtualisation.libvirtd.qemu.runAsRoot) [
        "input"
        "kvm"
        "libvitrd"
      ];
    };

    networking.firewall = {
      trustedInterfaces = mkIf cfg.libvirt [ "virbr0" ];
      interfaces =
        {
          "podman*".allowedUDPPorts = mkIf cfg.podman [
            53
            5353
          ];
        }
        // mapAttrs (_: _: {
          allowedUDPPorts = [
            53
            5353
          ];
        }) config.virtualisation.quadlet.networks;
    };

    security.unprivilegedUsernsClone = true;

    persist.state.directories = [
      "/var/lib/docker"
      "/var/lib/libvirt"
      "/var/lib/containers"
    ];

    home-manager = mkIf useHomeManager {
      users.${defaultUser} = {
        home.file.".config/containers/storage.conf".text = ''
          [storage]
          driver = "overlay"
        '';
        home.file.".config/libvirt/libvirt.conf".text = ''
          uri_default = "qemu:///system"
        '';
        persist.state.directories = [
          ".config/containers"
        ];
      };
    };
  };
}
