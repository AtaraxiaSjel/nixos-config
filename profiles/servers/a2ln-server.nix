{ pkgs, ... }: {
  systemd.user.services.a2ln-server = rec {
    serviceConfig = {
      TimeoutStartSec = 0;
      TimeoutStopSec = 10;
      Type = "simple";
      Restart = "always";
    };
    script = ''
      ${pkgs.a2ln}/bin/a2ln --pairing-port 23046 23045
    '';
    after = [ "graphical-session.target" ];
    wants = after;
    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 23045 23046 ];

  persist.state.homeDirectories = [ ".config/a2ln" ];
}