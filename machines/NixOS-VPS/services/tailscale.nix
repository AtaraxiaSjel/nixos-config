{ config, inputs, ... }:
let
  bridgeName = (import ../hardware/networks.nix).interfaces.main'.bridgeName;
  tailscalePort = config.services.tailscale.port;
  tailscaleIfname = config.services.tailscale.interfaceName;
  netbirdPort = config.services.netbird.clients.priv.port;
  netbirdIfname = config.services.netbird.clients.priv.interface;
  ssPort1 = 2234;
  ssPort2 = 2235;
in {
  imports = [ inputs.ataraxiasjel-nur.nixosModules.rinetd ];

  networking.firewall.trustedInterfaces = [ tailscaleIfname netbirdIfname ];
  networking.firewall.interfaces.${bridgeName} = {
    allowedUDPPorts = [ tailscalePort netbirdPort ];
    allowedTCPPorts = [ ssPort1 ssPort2 ];
  };

  systemd.network.networks."50-tailscale" = {
    matchConfig.Name = tailscaleIfname;
    linkConfig.Unmanaged = true;
    linkConfig.ActivationPolicy = "manual";
  };

  services.tailscale = {
    enable = true;
    port = 18491;
    useRoutingFeatures = "both";
  };

  services.netbird.clients.priv = {
    interface = "wt0";
    port = 52674;
    hardened = false;
    ui.enable = false;
    config = {
      AdminURL.Host = "net.ataraxiadev.com:443";
      AdminURL.Scheme = "https";
      ManagementURL.Host = "net.ataraxiadev.com:443";
      ManagementURL.Scheme = "https";
      DisableAutoConnect = false;
      RosenpassEnabled = true;
      RosenpassPermissive = true;
    };
  };
  users.users.${config.mainuser}.extraGroups = [ "netbird-priv" ];

  persist.state.directories = [ "/var/lib/tailscale" "/var/lib/netbird-priv" ];

  services.rinetd = {
    enable = true;
    settings = ''
      0.0.0.0 ${toString ssPort1} 100.64.0.2 ${toString ssPort1}
      0.0.0.0 ${toString ssPort2} 100.64.0.3 ${toString ssPort2}
    '';
  };
}