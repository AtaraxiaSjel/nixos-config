{ config, pkgs, lib, ... }:
let
  inherit (import ../hardware/networks.nix) interfaces;
  bridgeName = interfaces.main'.bridgeName;
  obfs4Port = 18371;
in {
  networking.firewall.interfaces.${bridgeName} = {
    allowedTCPPorts = [ obfs4Port ];
  };

  # We can get bridge cert from file: /var/lib/tor/pt_state/obfs4_bridgeline.txt
  # Fingerprint can be obtained from tor.service logs
  services.tor = {
    enable = true;
    enableGeoIP = true;
    client.enable = false;
    relay.enable = true;
    relay.role = "private-bridge";
    settings = {
      BridgeDistribution = "none";
      BridgeRelay = true;
      ContactInfo = "admin@ataraxiadev.com";
      ORPort = [ 17429 ];
      ServerTransportListenAddr = "obfs4 0.0.0.0:${toString obfs4Port}";
      Nickname = "Ataraxia";
    };
  };

  services.networkd-dispatcher = {
    enable = true;
    rules."restart-tor" = {
      onState = [ "routable" "off" ];
      script = ''
        #!${pkgs.runtimeShell}
        if [[ $IFACE == "${bridgeName}" && $AdministrativeState == "configured" ]]; then
          echo "Restarting Tor ..."
          systemctl restart tor
        fi
        exit 0
      '';
    };
  };
}