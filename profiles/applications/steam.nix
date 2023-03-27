{ pkgs, lib, config, ... }: {
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [
    pkgs.proton-ge
  ];

  startupApplications = [
    "${pkgs.steam}/bin/steam"
  ];

  systemd.user.services.x11-ownership = rec {
    script = ''
      doas chown ${config.mainuser} /tmp/.X11-unix
    '';
    after = [ "hyprland-session.target" ];
    wantedBy = [ "hyprland-session.target" ];
  };

  persist.state.homeDirectories = [
    ".local/share/Steam"
  ];

  # Start Steam only after the network is up
  # home-manager.users.${config.mainuser}.systemd.user.services.steam-startup = {
  #   Service = {
  #     ExecStart = "${pkgs.steam}/bin/steam";
  #     Type = "oneshot";
  #   };
  #   Unit = rec {
  #     After = if config.deviceSpecific.vpn.mullvad.enable then [
  #       "mullvad-daemon.service"
  #     ] else [
  #       "network-online.target"
  #     ];
  #     Wants = After;
  #   };
  #   Install.WantedBy = [ "hyprland-session.target" ];
  # };
}
