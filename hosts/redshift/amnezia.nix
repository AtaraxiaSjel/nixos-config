{
  config,
  lib,
  pkgs,
  secretsDir,
  flake-self,
  ...
}:
let
  inherit (config.virtualisation.quadlet) networks;
  inherit (lib.strings) versionOlder;
  webui-port = 32324;
  awg-port = 27649;
  webui-port-str = toString webui-port;
  awg-port-str = toString awg-port;
  awg = config.boot.kernelPackages.amneziawg;

  amneziawg =
    if versionOlder awg.version "1.0.20260210" then
      (awg.overrideAttrs (oa: {
        version = "1.0.20260210";
        src = pkgs.fetchFromGitHub {
          owner = "amnezia-vpn";
          repo = "amneziawg-linux-kernel-module";
          tag = "v1.0.20260210";
          hash = "sha256-w2TK0dE4fhEAgfaMKwaadVgle4cGEigQNHmXLkpxERA=";
        };
        patches = oa.patches or [ ] ++ [ (flake-self + /patches/amnezia-fix.patch) ];
      }))
    else
      awg;
in
{
  boot.kernelModules = [ "amneziawg" ];
  # TODO: remove after merged in upstream nixpkgs
  boot.extraModulePackages = [ amneziawg ];

  sops.secrets.awg-easy-redshift = {
    sopsFile = secretsDir + /redshift/amnezia.yaml;
    restartUnits = [ "awg-easy.service" ];
  };

  virtualisation.quadlet.networks = {
    br-services.networkConfig.dns = lib.mkForce [ "9.9.9.11" ];
  };

  virtualisation.quadlet.containers = {
    awg-easy = {
      autoStart = true;
      containerConfig = {
        environments = {
          WG_HOST = "138.124.104.112";
          WG_PORT = awg-port-str;
          PORT = webui-port-str;
          WG_DEFAULT_ADDRESS = "10.20.30.x";
          WG_DEFAULT_DNS = "9.9.9.11";
          WG_ALLOWED_IPS = "0.0.0.0/0, ::/0";
          WG_MTU = "1280";
          WG_PERSISTENT_KEEPALIVE = "25";
        };
        environmentFiles = [ config.sops.secrets.awg-easy-redshift.path ];
        # 0.2.16, latest
        image = "ghcr.io/ataraxiasjel/awg-easy@sha256:0b440508fc4d34921b688bc195af743855a203d2d6057d4079045a2f72e71f53";
        addCapabilities = [
          "NET_ADMIN"
          "NET_RAW"
          "SYS_MODULE"
        ];
        devices = [ "/dev/net/tun" ];
        sysctl = {
          "net.ipv4.ip_forward" = "1";
          "net.ipv4.conf.all.src_valid_mark" = "1";
        };
        networks = [ networks.br-services.ref ];
        publishPorts = [
          "127.0.0.1:${webui-port-str}:${webui-port-str}/tcp"
          "0.0.0.0:${awg-port-str}:${awg-port-str}/udp"
        ];
        volumes = [ "/srv/amneziawg:/etc/amnezia/amneziawg" ];
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ awg-port ];

  systemd.tmpfiles.rules = [ "d /srv/amneziawg 0700 root root -" ];
}
