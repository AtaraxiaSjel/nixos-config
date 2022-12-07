{ config, lib, pkgs, ... }: {
  home-manager.users.alukard = {
    home.packages = [ pkgs.sunshine ];
    systemd.user.services.sunshine = {
      Unit.Description = "Sunshine is a Gamestream host for Moonlight.";
      Service.ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
  networking.firewall = {
    allowedTCPPorts = [
      47984 47989 48010
      47990
    ];
    allowedUDPPorts = [
      47998 47999 48000 48002 48010
    ];
  };
}