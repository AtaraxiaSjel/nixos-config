{
  config,
  pkgs,
  ...
}:
let

  eturnal-conf = pkgs.writeText "eturnal.yml" ''
    eturnal:
      listen:
        -
          ip: "::"
          port: 3478
          transport: udp
        -
          ip: "::"
          port: 3478
          transport: tcp
        -
          ip: "::"
          port: 5349
          transport: tls
      tls_crt_file: /etc/eturnal/tls/fullchain.pem
      tls_key_file: /etc/eturnal/tls/key.pem
      relay_ipv4_addr: "46.253.132.218"
      #relay_ipv6_addr: "2001:db8::4"
      relay_min_port: 50201
      relay_max_port: 65535
      blacklist_peers:
        - "127.0.0.0/8"
        - "::1"
        - recommended
      strict_expiry: false
      ## Logging configuration:
      log_level: info           # critical | error | warning | notice | info | debug
      #log_rotate_size: 10485760
      #log_rotate_count: 10
      log_dir: stdout
      ## See: https://eturnal.net/doc/#Module_Configuration
      modules:
        mod_log_stun: {}        # Log STUN queries (in addition to TURN sessions).
        #mod_stats_prometheus:  # Expose STUN/TURN and VM metrics to Prometheus.
        #  ip: any              # This is the default: Listen on all interfaces.
        #  port: 8081           # This is the default.
        #  tls: false           # This is the default.
        #  vm_metrics: true     # This is the default.
  '';
in
{
  virtualisation.quadlet.containers.eturnal = {
    autoStart = true;
    containerConfig = {
      environments = {
        ETURNAL_SECRET__FILE = "/etc/eturnal/secret";
      };
      # Tags: 1.12.2-r2, 1.12, latest
      image = "ghcr.io/processone/eturnal@sha256:b13b84d5874f4c43092d0f04c351336afd3f1a590ad3dd802cbc810f4119f5dc";
      networks = [ "host" ];
      # networks = [ networks.br-services.ref ];
      readOnly = true;
      dropCapabilities = [ "ALL" ];
      noNewPrivileges = true;
      # publishPorts = [
      #   "3478:3478/tcp"
      #   "3478:3478/udp"
      #   "5349:5349/tcp"
      #   "5349:5349/udp"
      #   "50201-65535:50201-65535/udp"
      # ];
      volumes = [
        "${eturnal-conf}:/etc/eturnal.yml:ro"
        "/run/eturnal:/etc/eturnal/tls:ro"
        "${config.sops.secrets.tuwunel-eturnal-secret.path}:/etc/eturnal/secret:ro"
      ];
    };
  };
  networking.firewall.allowedTCPPorts = [
    3478
    5349
  ];
  networking.firewall.allowedUDPPorts = [
    3478
    5349
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 50201;
      to = 65535;
    }
  ];
}
