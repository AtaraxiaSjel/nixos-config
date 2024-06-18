{ config, ... }:
let
  homeDir = config.home-manager.users.${config.mainuser}.home.homeDirectory;
in {
  # TODO: enable websocket (--rpc-certificate)
  home-manager.users.${config.mainuser} = {
    programs.aria2 = {
      enable = true;
      settings = {
        dir = "${homeDir}/Downloads/aria2";
        listen-port = "6881-6999";
        # rpc-listen-port = 6800;
      };
    };
  };

}