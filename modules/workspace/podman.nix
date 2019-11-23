# cfg = config.devices.${config.device}.enableDocker;
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.podman;

  surroundEachWith = str: list:
    map (e: str + (toString e) + str) list;

  registriesConf = let
    registryList = list:
      "registries = [" + (concatStringsSep ", " (surroundEachWith "'" list)) + "]";
  in concatStringsSep "\n" (mapAttrsToList (type: registries: ''
    [registries.${type}]
    ${registryList registries}
  '') { inherit (cfg.registries) block insecure search; });

in {
  ###### interface

  options = {
    programs.podman = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whenever to configure <command>podman</command> user-wide.";
      };

      installSystemWide = mkOption {
        type = types.bool;
        default = false;
        description = "Install packages system-wide.";
      };

      registries = {
        search = mkOption {
          type = types.listOf types.str;
          default = [ "docker.io" "quay.io" ];
          description = ''
            List of repositories to search.
          '';
        };

        insecure = mkOption {
          default = [ ];
          type = types.listOf types.str;
          description = ''
            List of insecure repositories.
          '';
        };

        block = mkOption {
          default = [ ];
          type = types.listOf types.str;
          description = ''
            List of blocked repositories.
          '';
        };
      };

      policy = mkOption {
        default = {
          default = [ { type = "reject"; }];
        };
        type = types.attrs;
        example = literalExample ''
        {
          default = [ { type = "insecureAcceptAnything"; } ];
          transports = {
            docker-daemon = {
              "" = [ { type = "insecureAcceptAnything"; } ];
            };
          };
        }
        '';
        description = ''
          Signature verification policy file
          </para>
          <para>
          The default will simply reject everything.
        '';
      };
    };
  };

  ###### implementation

  config = mkMerge [
    (mkIf cfg.enable {
      home-manager.users.alukard.xdg.configFile = {
        "containers/libpod.conf".text = ''
          cgroup_manager = "systemd"
          cni_config_dir = "/etc/cni/net.d/"
          cni_default_network = "podman"
          cni_plugin_dir = ["${pkgs.cni-plugins}/bin/"]
          conmon_path = ["${pkgs.conmon}/bin/conmon"]
          image_default_transport = "docker://"
          runtime = "${pkgs.crun}/bin/crun"
          runtimes = ["${pkgs.crun}/bin/crun", "${pkgs.runc}/bin/runc"]
          # pause
          pause_image = "k8s.gcr.io/pause:3.1"
          pause_command = "/pause"
        '';
        "containers/registries.conf".text = registriesConf;
        "containers/policy.json".text = builtins.toJSON cfg.policy;
      };

      environment.etc."cni/net.d/87-podman-bridge.conflist".text = (builtins.toJSON {
        cniVersion = "0.3.0";
        name = "podman";
        plugins = [
          {
            type = "bridge";
            bridge = "cni0";
            isGateway = true;
            ipMasq = true;
            ipam = {
              type = "host-local";
              subnet = "10.88.0.0/16";
              routes = [
                { dst = "0.0.0.0/0"; }
              ];
            };
          }
          {
            type = "portmap";
            capabilities = {
              portMappings = true;
            };
          }
        ];
      });

      environment.systemPackages = mkIf cfg.installSystemWide
      (with pkgs; [
        buildah conmon crun fuse-overlayfs podman runc slirp4netns iptables podman-compose
      ]);

      home-manager.users.alukard.home.packages = mkIf (!cfg.installSystemWide)
      (with pkgs; [
        buildah conmon crun fuse-overlayfs podman runc slirp4netns iptables podman-compose
      ]);

      users.users.alukard = {
        subUidRanges = [{ startUid = 100000; count = 65536; }];
        subGidRanges = [{ startGid = 100000; count = 65536; }];
      };
    })
    ({
      programs.podman = {
        # enable = config.devices.${config.device}.enableDocker;
        enable = false;
        policy = {
          default = [ { type = "insecureAcceptAnything"; }];
        };
      };
    })
  ];
}