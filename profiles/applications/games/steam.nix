{ pkgs, lib, config, ... }: {
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [
    pkgs.proton-ge
  ];
  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = false;

  startupApplications = [ "steam" ];

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
    ".local/share/Colossal\\ Order/Cities_Skylines"
  ];
}
