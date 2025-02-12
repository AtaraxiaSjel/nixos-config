{ config, pkgs, ... }: {
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [
    pkgs.proton-ge-bin
  ];
  programs.steam.gamescopeSession.enable = true;
  programs.steam.gamescopeSession.env = {
    MANGOHUD = "1";
    CONNECTOR = "*,DP-3";
  };
  programs.steam.gamescopeSession.args = [
    "-w 2560"
    "-h 1440"
    "-W 2560"
    "-H 1440"
    "-r 144"
    "--hdr-enabled"
    "--hdr-itm-enable"
    "--adaptive-sync"
  ];

  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = false;

  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [ ckan ];
  };

  # startupApplications = [ "${pkgs.steam}/bin/steam" ];

  persist.state.homeDirectories = [
    ".local/share/Steam"
    ".steam"
  ] ++ [
    # Native games config
    ".config/WarThunder"
    ".local/share/BeamNG.drive"
    ".local/share/CKAN"
    ".local/share/Transistor"
    ".local/share/Paradox\ Interactive"
    ".paradoxlauncher"
  ];
}
