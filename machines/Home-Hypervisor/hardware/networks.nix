{
  domain = "home.ataraxiadev.com";
  hasIPv6 = false;
  interfaces = {
    main' = {
      mac = "d4:3d:7e:26:a8:af";
      bridgeName = "br0";
      ifname = "enp2s0";
      IPv4 = {
        address = "10.10.10.10/24";
        gateway = "10.10.10.1";
        dns = [ "10.10.10.1" "9.9.9.9" ];
      };
      IPv6 = {
        address = "";
        gateway = "";
        dns = [ ];
      };
    };
  };
}
