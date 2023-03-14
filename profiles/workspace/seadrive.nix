{ config, pkgs, lib, ... }: {
  # secrets.seadrive.owner = config.mainuser;
  secrets.seadrive-token.owner = config.mainuser;
  services.seadrive = {
    enable = true;
    mountPoint = "/media/seadrive";
    stateDir = "~/.config/seadrive";
    settings = {
      server = "https://file.ataraxiadev.com";
      username = "ataraxiadev@ataraxiadev.com";
      tokenFile = config.secrets.seadrive-token.decrypted;
      isPro = false;
      clientName = config.networking.hostName;
      sizeLimit = "4GB";
      cleanCacheInterval = 10;
    };
  };
  persist.state.homeDirectories = [ ".config/seadrive" ];
}