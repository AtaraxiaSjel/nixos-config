{ ... }: {
  containers.tinyproxy = {
    extraFlags = [ "-U" ];
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "192.168.0.6/24";
    config = { ... }: {
      services.privoxy = {
        enable = true;
        settings = {
          listen-address = "192.168.0.6:8888";
          toggle = false;
          keep-alive-timeout = 300;
          default-server-timeout = 60;
          connection-sharing = false;
        };
      };
      networking = {
        defaultGateway = "192.168.0.1";
        hostName = "tinyproxy-node";
        nameservers = [ "192.168.0.1" ];
        useHostResolvConf = false;
        firewall = {
          enable = true;
          allowedTCPPorts = [ 8888 ];
          rejectPackets = false;
        };
      };
      system.stateVersion = "24.11";
    };
  };
}