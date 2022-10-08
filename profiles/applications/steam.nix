{ pkgs, lib, config, ... }: {
  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;

  startupApplications = [
    "${pkgs.steam}/bin/steam"
  ];

  systemd.user.services.x11-ownership = rec {
    # serviceConfig.Type = "oneshot";
    script = ''
      chown alukard /tmp/.X11-unix
    '';
    after = [ "graphical-session.target" ];
    wants = after;
    wantedBy = [ "multi-user.target" ];
  };
}
