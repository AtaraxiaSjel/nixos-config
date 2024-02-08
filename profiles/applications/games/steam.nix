{ pkgs, ... }: {
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [
    pkgs.proton-ge
  ];
  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = false;

  startupApplications = [ "${pkgs.steam}/bin/steam" ];

  persist.state.homeDirectories = [
    ".local/share/Steam"
    ".steam"
  ] ++ [
    # Native games config
    ".config/WarThunder"
    ".local/share/BeamNG.drive"
  ];
}
