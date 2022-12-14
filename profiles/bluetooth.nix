{ config, pkgs, lib, ... }: {
  hardware.bluetooth = {
    enable = !isServer;
    # package = pkgs.bluez;
  };

  # systemd.services.bluetooth.serviceConfig.ExecStart = lib.mkForce [
  #   ""
  #   "${pkgs.bluez}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf -E"
  # ];

  persist.state.directories = [ "/var/lib/bluetooth" ];

  home-manager.users.${config.mainuser}.programs.zsh.shellAliases = let
    headphones = "D8:37:3B:60:5D:55";
  in {
    "hpc" = "bluetoothctl connect ${headphones}";
    "hpd" = "bluetoothctl disconnect ${headphones}";
  };
}