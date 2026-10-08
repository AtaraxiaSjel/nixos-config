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
  inherit (config.ataraxia.lists) ports;

  cfg = config.ataraxia.containers.tor;

  # Base torrc without secrets.
  torrcBase = pkgs.writeText "torrc.base" ''
    # Managed by Nix — do not edit inside the container.
    HardwareAccel 1
    Log notice stdout
    SafeLogging 1
    RunAsDaemon 0
    SocksPort 0.0.0.0:9150
    DNSPort 0.0.0.0:8853
    DataDirectory /var/lib/tor
  '';

  # Rebuilds /tmp/torrc from scratch on every start,
  # so container restarts never duplicate `Bridge` lines.
  torEntrypoint = pkgs.writeText "tor-entrypoint" ''
    #!/bin/bash
    set -euo pipefail

    BASE="/etc/tor/torrc.base"
    SECRET="/run/tor/bridges"
    OUT="/tmp/torrc"
    DATA_DIR="/var/lib/tor"

    mkdir -p "$DATA_DIR" /run/tor
    chmod 700 "$DATA_DIR" || true

    cat "$BASE" > "$OUT"

    LYREBIRD="$(command -v lyrebird || true)"
    if [ -z "$LYREBIRD" ]; then
      for c in /bin/lyrebird /usr/bin/lyrebird /usr/local/bin/lyrebird; do
        if [ -x "$c" ]; then
          LYREBIRD="$c"
          break
        fi
      done
    fi
    LYREBIRD="''${LYREBIRD:-/bin/lyrebird}"

    # PT handshake smoke test. The real transport prints
    # `CMETHODS DONE` and exits 0 on stdin EOF; anything else
    # (e.g. an unrelated binary sharing the name) aborts startup
    # here with a clear message instead of tor's retry loop.
    PT_SMOKE_DIR="$(mktemp -d)"
    if ! timeout 10 env TOR_PT_MANAGED_TRANSPORT_VER=1 TOR_PT_STATE_LOCATION="$PT_SMOKE_DIR" TOR_PT_EXIT_ON_STDIN_CLOSE=1 TOR_PT_CLIENT_TRANSPORTS=obfs4 "$LYREBIRD" </dev/null >"$PT_SMOKE_DIR/handshake" 2>"$PT_SMOKE_DIR/stderr"; then
      echo "tor-entrypoint: ERROR: pluggable transport $LYREBIRD failed the handshake smoke test:" >&2
      cat "$PT_SMOKE_DIR/stderr" >&2 || true
      rm -rf "$PT_SMOKE_DIR"
      exit 1
    fi
    if ! grep -q "CMETHODS DONE" "$PT_SMOKE_DIR/handshake"; then
      echo "tor-entrypoint: ERROR: $LYREBIRD did not complete the PT handshake (no CMETHODS DONE)" >&2
      rm -rf "$PT_SMOKE_DIR"
      exit 1
    fi
    rm -rf "$PT_SMOKE_DIR"

    if [ -f "$SECRET" ] && [ -s "$SECRET" ]; then
      sed -e "s#/usr/bin/lyrebird#$LYREBIRD#g" -e "s#/usr/local/bin/lyrebird#$LYREBIRD#g" "$SECRET" >> "$OUT"
      if ! grep -qi '^[[:space:]]*ClientTransportPlugin' "$OUT"; then
        echo "ClientTransportPlugin obfs4 exec $LYREBIRD" >> "$OUT"
      fi
    else
      echo "tor-entrypoint: WARN: bridge file $SECRET missing or empty, starting without bridges" >&2
    fi

    echo "tor-entrypoint: verifying config" >&2
    if ! /bin/tor --verify-config -f "$OUT"; then
      echo "tor-entrypoint: ERROR: invalid torrc, dumping:" >&2
      cat "$OUT" >&2 || true
      exit 1
    fi

    exec /bin/tor -f "$OUT"
  '';

  torImage = pkgs.dockerTools.buildLayeredImage {
    name = "tor-socks-proxy";
    tag = "latest";
    contents = [
      pkgs.tor
      pkgs.obfs4
      pkgs.bash
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
      pkgs.curl
      pkgs.dockerTools.caCertificates
    ];
    fakeRootCommands = ''
      mkdir -p ./etc/tor ./var/lib/tor ./usr/local/bin ./usr/bin ./tmp ./run/tor
      cp ${torrcBase} ./etc/tor/torrc.base
      cp ${torEntrypoint} ./usr/local/bin/tor-entrypoint
      chmod 0555 ./usr/local/bin/tor-entrypoint
      chmod 0444 ./etc/tor/torrc.base
      # Compat: the sops secret was written for Alpine
      # (`/usr/bin/lyrebird`); the entrypoint rewrites it to
      # /bin/lyrebird, this symlink covers anything bypassing that.
      ln -sf /bin/lyrebird ./usr/bin/lyrebird
      chmod 0700 ./var/lib/tor
      chmod 1777 ./tmp
    '';
    config = {
      Entrypoint = [
        "/bin/bash"
        "/usr/local/bin/tor-entrypoint"
      ];
      ExposedPorts = {
        "9150/tcp" = { };
        "8853/udp" = { };
      };
      Env = [ "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt" ];
    };
  };

  # End-to-end check: fetch clearnet API *through* the SOCKS proxy.
  healthCmd = "curl --fail --max-time 20 --socks5-hostname 127.0.0.1:9150 https://check.torproject.org/api/ip";
in
{
  options.ataraxia.containers.tor = {
    enable = mkEnableOption "Enable tor client container";
  };

  config = mkIf cfg.enable {
    sops.secrets.tor-container = {
      sopsFile = secretsDir + /proxy.yaml;
      # Apply bridge rotation without manual intervention.
      restartUnits = [ "tor-proxy.service" ];
    };

    virtualisation.quadlet = {
      # Persistent cache: faster bootstrap, less load, survives reboots.
      volumes.tor-data = {
        autoStart = true;
        volumeConfig = { };
      };

      # Local archive — loaded from /nix/store, never pulled.
      images.tor-proxy = {
        autoStart = true;
        imageConfig = {
          image = "docker-archive:${torImage}";
          tag = "localhost/tor-socks-proxy:latest";
        };
      };

      containers.tor-proxy = {
        autoStart = true;
        unitConfig = {
          # Order after host network + decrypted secrets. The old build
          # unit had no ordering, so it raced DNS at boot.
          After = [
            "network-online.target"
            "sops-nix.service"
          ];
          Wants = [ "network-online.target" ];
        };
        serviceConfig = {
          Restart = "always";
          RestartSec = "10s";
          TimeoutStartSec = "120s";
          TimeoutStopSec = "35s";
        };
        containerConfig = {
          image = config.virtualisation.quadlet.images.tor-proxy.ref;
          # Never contact a registry at runtime: image comes from the
          # `images.tor-proxy` unit above.
          pull = "never";
          networks = [ networks.br-services.ref ];
          publishPorts = [
            "0.0.0.0:${ports.tor.str}:9150/tcp"
            "0.0.0.0:${ports.tor-dns.str}:8853/udp"
          ];
          volumes = [
            "${config.sops.secrets.tor-container.path}:/run/tor/bridges:ro"
            "${config.virtualisation.quadlet.volumes.tor-data.ref}:/var/lib/tor"
          ];
          # Hardening: tor needs no caps for high ports; read-only root
          # with tmpfs for /tmp (/tmp/torrc) and /run.
          dropCapabilities = [ "all" ];
          noNewPrivileges = true;
          readOnly = true;
          readOnlyTmpfs = true;
          stopSignal = "SIGINT";
          stopTimeout = 30;
          # Health: generous startup window, auto-restart on stall.
          healthCmd = healthCmd;
          healthInterval = "60s";
          healthTimeout = "30s";
          healthRetries = 3;
          healthStartPeriod = "180s";
          healthStartupCmd = healthCmd;
          healthStartupInterval = "15s";
          healthStartupRetries = 12;
          healthStartupTimeout = "20s";
          healthStartupSuccess = 1;
          healthOnFailure = "restart";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [ ports.tor.int ];
    networking.firewall.allowedUDPPorts = [ ports.tor-dns.int ];
  };
}
