{ config, lib, pkgs, ... }:
let
  homeDir = config.home-manager.users.${config.mainuser}.home.homeDirectory;
in {
  # TODO: enable websocket (--rpc-certificate)
  services.aria2 = {
    enable = true;
    downloadDir = "/media/aria2";
    rpcListenPort = 6800;
    # FIXME: I can expose this, since i listen rpc only on localhost
    # but in future it's better to implement read key from secrets before start daemon
    rpcSecret = "secret";
    # listenPortRange = {};
    openPorts = false;
  };
  # networking.firewall.allowedTCPPorts = [ config.services.aria2.rpcListenPort ];
  persist.state.directories = [ "/media/ari2" ];
}