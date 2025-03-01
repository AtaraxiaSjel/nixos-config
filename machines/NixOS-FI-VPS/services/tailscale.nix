{ config, inputs, ... }:
let
  bridgeName = (import ../hardware/networks.nix).interfaces.main'.bridgeName;
  tailscalePort = config.services.tailscale.port;
  tailscaleIfname = config.services.tailscale.interfaceName;
  ssPort1 = 2234;
  ssPort2 = 2235;
in {
  imports = [ inputs.ataraxiasjel-nur.nixosModules.rinetd ];

  networking.firewall.trustedInterfaces = [ tailscaleIfname ];
  networking.firewall.interfaces.${bridgeName} = {
    allowedUDPPorts = [ tailscalePort ];
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

  persist.state.directories = [ "/var/lib/tailscale" ];

  services.rinetd = {
    enable = true;
    settings = ''
      0.0.0.0 ${toString ssPort1} 100.64.0.1 ${toString ssPort1}
      0.0.0.0 ${toString ssPort2} 100.64.0.2 ${toString ssPort2}
    '';
  };
}