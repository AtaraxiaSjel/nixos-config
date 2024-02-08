{ config, ... }:
let
  bridgeName = (import ../hardware/networks.nix).interfaces.main'.bridgeName;
  tailscalePort = config.services.tailscale.port;
  tailscaleIfname = config.services.tailscale.interfaceName;
in {
  networking.firewall.interfaces.${bridgeName}.allowedUDPPorts = [ tailscalePort ];
  networking.firewall.trustedInterfaces = [ tailscaleIfname ];

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
}