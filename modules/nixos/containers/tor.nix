{
  config,
  lib,
  pkgs,
  secretsDir,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.virtualisation.quadlet) networks;

  cfg = config.ataraxia.containers.tor;
  dockerfile = pkgs.writeText "Dockerfile.tor" ''
    FROM alpine:3

    LABEL name="tor-socks-proxy"
    LABEL version="latest"

    RUN echo '@edge https://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories && \
        echo '@edge https://dl-cdn.alpinelinux.org/alpine/edge/testing'   >> /etc/apk/repositories && \
        apk -U upgrade && \
        apk -v add tor@edge lyrebird@edge curl && \
        chmod 700 /var/lib/tor && \
        rm -rf /var/cache/apk/* && \
        tor --version

    RUN echo -e "HardwareAccel 1\nLog notice stdout\nDNSPort 0.0.0.0:8853\nSocksPort 0.0.0.0:9150\nDataDirectory /var/lib/tor" > /etc/tor/torrc && \
        chown tor:root /etc/tor/torrc

    HEALTHCHECK --timeout=30s --start-period=60s \
        CMD curl --fail --socks5-hostname localhost:9150 -I -L 'https://protonmailrmez3lotccipshtkleegetolb73fuirgj7r4o4vfu7ozyd.onion' || exit 1

    USER tor
    EXPOSE 8853/udp 9150/tcp

    CMD ["/usr/bin/tor", "-f", "/etc/tor/torrc"]
  '';
in
{
  options.ataraxia.containers.tor = {
    enable = mkEnableOption "Enable tor client container";
  };

  config = mkIf cfg.enable {
    sops.secrets.tor-container.sopsFile = secretsDir + /proxy.yaml;
    sops.secrets.tor-container.mode = "0444";
    virtualisation.quadlet = {
      builds.tor-proxy = {
        autoStart = true;
        buildConfig = {
          file = toString dockerfile;
          tag = "tor-socks-proxy:latest";
        };
      };
      containers.tor-proxy = {
        autoStart = true;
        containerConfig = {
          exec = "sh -c 'cat /home/torrc-extra >> /etc/tor/torrc && /usr/bin/tor -f /etc/tor/torrc'";
          image = config.virtualisation.quadlet.builds.tor-proxy.ref;
          networks = [ networks.br-services.ref ];
          publishPorts = [
            "0.0.0.0:9150:9150/tcp"
            "0.0.0.0:8853:8853/udp"
          ];
          volumes = [
            "${config.sops.secrets.tor-container.path}:/home/torrc-extra:ro"
          ];
        };
      };
    };
    networking.firewall.allowedTCPPorts = [ 9150 ];
    networking.firewall.allowedUDPPorts = [ 8853 ];
  };
}
