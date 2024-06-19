{ config, ... }: {
  # TODO: enable websocket (--rpc-certificate)
  home-manager.users.${config.mainuser} = { config, ...}: {
    programs.aria2 = {
      enable = true;
      settings = {
        dir = "${config.home.homeDirectory}/Downloads/aria2";
        listen-port = "6881-6999";
        # rpc-listen-port = 6800;
      };
    };
  };

}