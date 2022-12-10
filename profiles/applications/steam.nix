{ pkgs, lib, config, ... }: {
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  # startupApplications = [
  #   "${pkgs.steam}/bin/steam"
  # ];

  # systemd.user.services.x11-ownership = rec {
  #   # serviceConfig.Type = "oneshot";
  #   script = ''
  #     chown ${config.mainuser} /tmp/.X11-unix
  #   '';
  #   after = [ "graphical-session.target" ];
  #   wants = after;
  #   wantedBy = [ "graphical-session-pre.target" ];
  # };

  # Start Steam only after the network is up
  # home-manager.users.${config.mainuser}.systemd.user.services.steam-startup = {
  #   Service = {
  #     ExecStart = "${pkgs.steam}/bin/steam";
  #     Type = "oneshot";
  #   };
  #   Unit = rec {
  #     # After = if config.deviceSpecific.wireguard.enable then [
  #     #   "mullvad-daemon.service"
  #     # ] else [
  #     #   "network-online.target"
  #     # ];
  #     After = [ "network-online.target" ];
  #     Wants = After;
  #   };
  #   Install.WantedBy = [ "graphical-session-pre.target" ];
  # };
}
