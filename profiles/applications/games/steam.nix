{ pkgs, lib, config, ... }: {
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [
    pkgs.proton-ge
  ];
  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = false;

  # startupApplications = [ "steam" ];
  startupApplications = let
    gs = pkgs.writeShellScriptBin "gamescope-steam" ''
      gamescope --steam --borderless -- steam
    '';
  in [
    # "${gs}/bin/gamescope-steam"
    "${pkgs.steam}/bin/steam"
  ];

  systemd.user.services.x11-ownership = {
    script = ''
      doas chown ${config.mainuser} /tmp/.X11-unix
    '';
    after = [ "hyprland-session.target" ];
    wantedBy = [ "hyprland-session.target" ];
  };

  persist.state.homeDirectories = [
    ".local/share/Steam"
    ".steam"
  ] ++ [
    # Games configs
    ".config/WarThunder"
    ".local/share/BeamNG.drive"
  ];
}
