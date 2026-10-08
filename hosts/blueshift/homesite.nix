{
  config,
  pkgs,
  lib,
  secretsDir,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  sops.secrets.tinc-mesh-ed25519 = {
    sopsFile = secretsDir + /${config.networking.hostName}/homesite.yaml;
    restartUnits = [ "tinc.mesh.service" ];
  };
  sops.secrets.tinc-mesh-rsa = {
    sopsFile = secretsDir + /${config.networking.hostName}/homesite.yaml;
    restartUnits = [ "tinc.mesh.service" ];
  };
  sops.secrets.wgsite-private-key = {
    sopsFile = secretsDir + /${config.networking.hostName}/homesite.yaml;
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
    bird2
    tinc_pre
    tcpdump
    mtr
    iputils
  ];

  # --- Forwarding and asymmetry protection ---
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = mkForce 1;
    "net.ipv4.conf.all.forwarding" = mkForce 1;
    "net.ipv4.conf.default.forwarding" = mkForce 1;
    # Loose RPF: OSPF failover changes the ingress interface (wgdirect/wgsite/mesh),
    # Strict RPF would drop return traffic. 2 = loose.
    "net.ipv4.conf.all.rp_filter" = mkForce 2;
    "net.ipv4.conf.default.rp_filter" = mkForce 2;
    # PLPMTUD as a second line of defense alongside MSS-clamp (heals blackhole without ICMP).
    "net.ipv4.tcp_mtu_probing" = mkForce 1;
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [
      36591
      655
    ];
    allowedTCPPorts = [ 655 ];
    checkReversePath = "loose";
    trustedInterfaces = [
      "wgsite"
      "tinc.mesh"
    ];
  };

  # --- Native MSS-clamp via nftables (analog of OpenWrt mtu_fix=1) ---
  # Without it large TCP segments (SSH ls -la, LuCI) hang the session:
  # DF=1 + ICMP NeedFrag blocked (CGNAT/PPPoE 1492 + WG overhead 60) = PMTUD blackhole.
  # The rule clamps MSS in SYN/SYN-ACK to the interface PMTU (1280 -> MSS ~1240).
  networking.nftables = {
    enable = true;
    tables = {
      mangle-mss = {
        family = "inet";
        content = ''
          chain forward-mss {
            type filter hook forward priority -150; policy accept;
            oifname { "wgsite", "tinc.mesh" } tcp flags syn tcp option maxseg size set rt mtu
            iifname { "wgsite", "tinc.mesh" } tcp flags syn tcp option maxseg size set rt mtu
          }
        '';
      };
    };
  };

  # --- WireGuard hub: single multipoint interface instance, two peers ---
  networking.wireguard = {
    enable = true;
    useNetworkd = true;
    interfaces.wgsite = {
      ips = [ "10.10.90.65/26" ];
      listenPort = 36591;
      privateKeyFile = config.sops.secrets.wgsite-private-key.path;
      mtu = 1280;
      # false = analog of OpenWrt route_allowed_ips 0: only Bird installs LAN routes.
      # Otherwise WG statics would override OSPF cost and failover would not work.
      allowedIPsAsRoutes = false;
      peers = [
        {
          # site_a (Router A)
          publicKey = "ZDyDGc5NB8Lpig+33RNbcLPJ8uTv0p+gNZUvejQZj3s=";
          allowedIPs = [
            "10.10.90.66/32"
            "10.10.10.0/24"
          ];
        }
        {
          # site_b (Router B, CGNAT)
          publicKey = "nb+aLKCQS8eGvTzgw2BDjubqs2J+hj1dR3X50SFtSkY=";
          allowedIPs = [
            "10.10.90.67/32"
            "192.168.0.0/24"
          ];
        }
      ];
    };
  };

  # --- Tinc mesh (switch/tap): coordinated via the VPS ---
  # The VPS only listens (no ConnectTo), both routers ConnectTo vps.
  # switch is a deliberate choice: in router-mode only unicast is supported
  # and tinc installs Subnet routes itself (conflicts with Bird); in switch mode the L2 domain
  # keeps LAN routes installed only by OSPF. See tinc.conf(5) Mode.
  systemd.network.networks."30-tinc-mesh" = {
    matchConfig.Name = "tinc.mesh";
    address = [ "10.10.90.129/26" ];
    linkConfig.MTUBytes = "1280";
    networkConfig = {
      # Do not pull default via tinc, only our prefixes from Bird.
      DHCP = "no";
      IPv6AcceptRA = false;
    };
  };

  services.tinc.networks."mesh" = {
    name = "vps";
    chroot = false;
    interfaceType = "tap";
    debugLevel = 2;
    ed25519PrivateKeyFile = config.sops.secrets.tinc-mesh-ed25519.path;
    rsaPrivateKeyFile = config.sops.secrets.tinc-mesh-rsa.path;
    extraConfig = ''
      Mode = switch
      DeviceType = tap
      # Interface is intentionally NOT set: the NixOS module default is tinc.mesh,
      # which systemd.network (Name=tinc.mesh) and Bird
      # (interface "tinc.mesh") are written against. If Interface = mesh is set, the device
      # will be renamed to mesh and both places will stop seeing it.
      Port = 655
      PingInterval = 10
      PingTimeout = 5
      ClampMSS = yes
      PMTUDiscovery = yes
      Compression = 0
      LocalDiscovery = yes
    '';
    hosts = {
      vps = ''
        Address = blueshift.ataraxiadev.com
        Port = 655
        Ed25519PublicKey = Itmuyal1rc3tc1sML+CS8P+RQAakp7P8dtWyd1UqWkE
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAk/iooaB0ztYD9oqPV5BNVQU9QCXCBLqU9GvsXHBE1tyIM3D5s2KR
        FZ7zsB8q9vJIPcOgWWbJBenOMhNchFaeNMsktC82TsfqM17cYN9Gs0T8ZB2eCTLP
        r1VQWLDn9jNanNbeLmMBvhBLgxjZaMWfRNLdqlz3AF+sK1nJ4ZijePuUGUYUp4Dh
        T6HH4BvLphbkhlHF2P7JiwIglzaf1fpGSLlQjd17jBDcNuijOmjcJ5S8Jk88qbzv
        WAm/UR89LvtflJphuIyQ44lhFvPOxGJGenrQLoaNTs1dm/F3Gr96r4l4G7EHbql+
        K2DniypVEUX/tsaOS95FbZsoVD7rTfya/Ki1zmr/oQfXiP9G9d8kSs/E5VRGNeTT
        ESdCfE+w+XYzlzj/J65dY8fornqxmeP/g4f0e7m887JWUjmW5E+NbsFgVX9NaLv0
        J9TrTVHvOGhMOAAzPB9pyFrLXKCmiiLCVrPqUgRwgaEMOdrTQRSWjdVkSVFP+8hV
        6+cxITYps9o7YXg0VxiTPtoiWrIiBHzKXCbgaQPdzTQxKilRZO4tPYUO/cJQuEbF
        qr1NGFE93mwnUAXecdFeMrx+fztTFXqsWD3HiOg4gEMLD1T5I3nhR22m/Lqq0p4w
        9oNJEO+ShOeOaUNKakfw2D9d+gb667XnVbzsS9f+XrQEynt3rmrm7AUCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      site_a = ''
        Address = home.ataraxiadev.com
        Port = 655
        Ed25519PublicKey = 448T7EKnyHdFq0wl04LrhvgWb/+Pbc5Bl54RWECdbhJ
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAmjGOKRugQ6Tp2zfxf07TkR7+df/F2eKOVwqwWYquot88duFTZb/D
        szgmiQ/ymVqhYBKd5k0sXNtHqpwTwkbb01xb3Lbfg1Ul7UMGQXwJxcKrGP3JG4ml
        VUJ5OlI2frqHcj1vjb6oR58ANDoJ1AioeD3Y8wt8wB2Uh6OdAwJbiBLAziZnz2Xc
        iKqXb3nRiOUL3Bh+Rn1gysDM0wq/1WASVsGrHZ4L145s284MY1Ih4cinj/Oj3V8y
        aV2XbTXalqVgUMWOOHAwCvACTIo0k6kw9d4B1DOOXQ4CFj+bFrzoztnGvl+/sTNf
        Vb+Lzlvl20jOBgQ9tILZEBri+d1qv0ueDQC7+lQYlh2YcrJX3+/2Kv/utEZ5AQ9i
        HWRGAPV4//J4yU0hZfhwyC2jU7QTc+n0bcinPzzl1Mj/7nGocFjMWjgfQoW21l1R
        tZWBizr9HfRhqeDkJzTZAMP8UETeqqvb3jtaWu9X1WRYURM5POxhHb6FhRXI2uQ7
        qJUOUIESubB8bFg5/Evj/NdgPUwinQVWfJJmxztAVeK26BZkmIO2YfPVJPIfsoJm
        GBY5Qh8gK5jrOTJj3G1S2QWj8iWSXpTee0GNObb5xM+m8VG6tF4AL3NvGhU4JRYz
        oYMAnzHRJi2omtJF/qkxE7D5E0f/E/aSB0juSk4SCKnZ7D8pq1L9QSMCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      site_b = ''
        Port = 655
        Ed25519PublicKey = lFJiifzxQBWHpyKU7X1ak+sQLpDB2WSGA6r3tqgtdoI
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAmzW2IBRglqVUx1JuuxyDeE8tz3PGKL/zxwAryS/PuM8jKUH6d7Ml
        JOD/ts9/RBPFi4+WNZSSn1lRPYACHs/hetjYdtmcmDtPd5a0b+zmJ6Pef3RBuE8+
        fBVnexQhea64ecr7t+6HkW/S8v/KYaribp/KzqXD6p4dAEWe9ZdGf3JJGfY34BFp
        zaJG5k6Fz5MriqNcwg06YnXQ5P2Wk8VdcqqjBEa1IR0rZELftdBcDI4+GkO/F8VQ
        Jfth4BBERlEIcvCpjBnSGSJ+fp4sHDWINOR/0BsGAwID5E90tIwcKsk+A/2x4Ica
        HTA1aXpshjO9v6K0q5JiNZClg3Hlm+r6wa88p6PgW341MVRXjBFXC4SR9TgRX2w0
        KEiMU0/X6HSGmSalWhdp8nRFB13bJ2LqtHGPFrY0IORnuFQn4Wd7ifqgN75Sm+1Y
        HKqElq99TXxZktauZWZsZTZpQyCbKgCcXgRvxgfAfwuu2E4IlugiYZ3o8PKW0M+H
        RLg0+3sUgt2m8mAw9Cwc0BTiHAFodfDFqL44jHVYYadR8VxCKhol3MF/Bs+CxBV2
        zfYevM5Bb32y9rny4lCee4K11GixLGvY9ajOKSuWOVL8fleCU2YIOy69mHT/IfMG
        ZLoccKBdRmkVplHuU+BLBcTabmSdD/loiNtZSKQzAz/yW97yJH78f5ECAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
    };
  };

  systemd.services."tinc.mesh".after = [ "network-online.target" ];
  systemd.services."tinc.mesh".wants = [ "network-online.target" ];

  # --- Bird2 OSPFv2: transit hub, DR for both NBMA domains ---
  services.bird = {
    enable = true;
    package = pkgs.bird2;
    config = ''
      router id 10.10.90.65;

      protocol device {
        scan time 10;
      }

      protocol kernel {
        scan time 10;
        ipv4 {
          import none;
          export all;
        };
      }

      protocol bfd {
        interface "wgsite" { interval 1000 ms; multiplier 3; };
        interface "tinc.mesh" { interval 1000 ms; multiplier 3; };
      };

      # NBMA: unicast Hello to each neighbor (multicast over multipoint-WG
      # is not fanned out — the first AllowedIPs would win everything). VPS is DR (priority 10),
      # routers are priority 0. hello/poll/dead must match on all three.
      protocol ospf v2 main {
        ipv4 {
          import all;
          export all;
        };
        area 0.0.0.0 {
          interface "wgsite" {
            type nbma;
            cost 100;
            hello 5;
            poll 5;
            dead 15;
            retransmit 5;
            priority 10;
            bfd on;
            tx length 1280;
            neighbors {
              10.10.90.66;
              10.10.90.67;
            };
          };
          interface "tinc.mesh" {
            type nbma;
            cost 200;
            hello 5;
            poll 5;
            dead 15;
            retransmit 5;
            priority 10;
            bfd on;
            tx length 1280;
            neighbors {
              10.10.90.130;
              10.10.90.131;
            };
          };
        };
      }
    '';
  };
}
