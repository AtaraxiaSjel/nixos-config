rec {
  privateIPv6Prefix = "fd3a:900e:8e74:ffff";
  domain = "wg.ataraxiadev.com";
  hasIPv6 = false;

  interfaces = {
      # This is the public-facing interface. Any interface name with a prime
      # symbol means it's a public-facing interface.
      main' = {
        mac = "bc:24:11:6b:56:8a";
        bridgeName = "br0";
        ifname = "enp0s18";
        IPv4 = {
          address = "104.164.54.197/24";
          gateway = "104.164.54.1";
          dns = [ "9.9.9.9" "149.112.112.112" ];
        };
        IPv6 = {
          address = "";
          gateway = "";
          dns = [ ];
        };
      };

      wireguard0 = {
        ifname = "wg0";
        dns = [ "${privateIPv6Prefix}::0:53" ];
        IPv4 = {
          address = "10.100.0.1";
          subnet = "10.100.0.0/16";
        };
        IPv6 = {
          address = "${privateIPv6Prefix}::1";
          subnet = "${privateIPv6Prefix}::0/64";
        };
      };
    };

  # Wireguard-related things.
  wireguardPort = 40820;
  wireguardIPv4Prefix = "10.100.0";
  wireguardIPv6Prefix = "${privateIPv6Prefix}::0";
  wireguardPeers = {
    server = with interfaces.wireguard0; {
      IPv4 = IPv4.address;
      IPv6 = IPv6.address;
    };
    ataraxia = {
      IPv4 = "${wireguardIPv4Prefix}.2";
      IPv6 = "${wireguardIPv6Prefix}:2";
    };
    hypervisor = {
      IPv4 = "${wireguardIPv4Prefix}.3";
      IPv6 = "${wireguardIPv6Prefix}:3";
    };
    mikrotik = {
      IPv4 = "${wireguardIPv4Prefix}.4";
      IPv6 = "${wireguardIPv6Prefix}:4";
    };
    poco = {
      IPv4 = "${wireguardIPv4Prefix}.5";
      IPv6 = "${wireguardIPv6Prefix}:5";
    };
    kpoxa = {
      IPv4 = "${wireguardIPv4Prefix}.6";
      IPv6 = "${wireguardIPv6Prefix}:6";
    };
    kpoxa2 = {
      IPv4 = "${wireguardIPv4Prefix}.7";
      IPv6 = "${wireguardIPv6Prefix}:7";
    };
    faysss = {
      IPv4 = "${wireguardIPv4Prefix}.8";
      IPv6 = "${wireguardIPv6Prefix}:8";
    };
    faysss2 = {
      IPv4 = "${wireguardIPv4Prefix}.9";
      IPv6 = "${wireguardIPv6Prefix}:9";
    };
    faysss3 = {
      IPv4 = "${wireguardIPv4Prefix}.10";
      IPv6 = "${wireguardIPv6Prefix}:a";
    };
    doste = {
      IPv4 = "${wireguardIPv4Prefix}.11";
      IPv6 = "${wireguardIPv6Prefix}:b";
    };
    dell = {
      IPv4 = "${wireguardIPv4Prefix}.12";
      IPv6 = "${wireguardIPv6Prefix}:c";
    };
    hypervisor-dns = {
      IPv4 = "${wireguardIPv4Prefix}.13";
      IPv6 = "${wireguardIPv6Prefix}:d";
    };
  };
}
