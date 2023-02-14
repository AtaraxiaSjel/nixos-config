{ pkgs, lib, config, ... }: {
  programs.steam.enable = true;
  hardware.steam-hardware.enable = false;

  programs.java.enable = true;
  programs.java.package = pkgs.jre8;

  # programs.firejail.wrappedBinaries.steam = {
  #   executable = "${lib.getBin pkgs.steam}/bin/steam";
  #   profile = "${pkgs.firejail}/etc/firejail/steam.profile";
  # };

  startupApplications = [
    "${pkgs.steam}/bin/steam"
  ];

  persist.state.homeDirectories = [
    ".local/share/Steam"
  ];

  systemd.user.services.x11-ownership = rec {
    script = ''
      doas chown ${config.mainuser} /tmp/.X11-unix
    '';
    after = [ "hyprland-session.target" ];
    wantedBy = [ "hyprland-session.target" ];
  };

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
