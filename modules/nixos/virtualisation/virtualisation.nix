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
    mkMerge
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

  config = mkMerge [
    {
      virtualisation = {
        oci-containers.backend = if (!cfg.podman && cfg.docker) then "docker" else "podman";
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
        quadlet = {
          enable = cfg.podman;
          autoEscape = true;
          autoUpdate.enable = false;
          networks = {
            br-services.networkConfig = {
              disableDns = false;
              dns = [
                "10.10.10.9"
                "10.10.10.1"
              ];
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

      networking.firewall = {
        trustedInterfaces = mkIf cfg.libvirt [ "virbr0" ];
        interfaces = {
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

      persist.state.files = [
        "/etc/subuid"
        "/etc/subgid"
      ];
    }

    (mkIf cfg.libvirt {
      virtualisation = {
        libvirtd = {
          enable = true;
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
        spiceUSBRedirection.enable = true;
      };

      environment.systemPackages = [ pkgs.virtiofsd ];

      users.users."qemu-libvirtd" = mkIf cfg.libvirt {
        extraGroups = lib.optionals (!config.virtualisation.libvirtd.qemu.runAsRoot) [
          "input"
          "kvm"
          "libvitrd"
        ];
      };

      persist.state.directories = [ "/var/lib/libvirt" ];

      home-manager = mkIf useHomeManager {
        users.${defaultUser}.home.file.".config/libvirt/libvirt.conf".text = ''
          uri_default = "qemu:///system"
        '';
      };
    })

    (mkIf cfg.docker {
      virtualisation.docker = {
        enable = true;
        daemon.settings = {
          features = {
            buildkit = true;
          };
        };
        storageDriver = "overlay2";
      };

      environment.systemPackages = [ pkgs.docker-compose ];

      persist.state.directories = [ "/var/lib/docker" ];
    })

    (mkIf cfg.podman {
      virtualisation.podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
        dockerCompat = !config.virtualisation.docker.enable;
        dockerSocket.enable = !config.virtualisation.docker.enable;
      };

      environment.systemPackages = [ pkgs.podman-compose ];

      persist.state.directories = [ "/var/lib/containers" ];

      home-manager = mkIf useHomeManager {
        users.${defaultUser} = {
          home.file.".config/containers/storage.conf".text = ''
            [storage]
            driver = "overlay"
          '';
          persist.state.directories = [
            ".config/containers"
            {
              directory = ".local/share/containers";
              method = "symlink";
            }
          ];
        };
      };
    })
  ];
}
