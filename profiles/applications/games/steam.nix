{ config, pkgs, ... }: {
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [
    pkgs.proton-ge-bin
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
