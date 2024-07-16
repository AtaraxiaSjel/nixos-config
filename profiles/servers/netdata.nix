{ lib, pkgs, ... }: {
  services.netdata = {
    enable = true;
    enableAnalyticsReporting = lib.mkForce false;
    # package = (pkgs.netdata.override { withConnPrometheus = true; });
  };
  systemd.services.netdata.path = lib.mkAfter [ pkgs.jq ];

  persist.state.directories = [ "/var/lib/netdata" ];
}