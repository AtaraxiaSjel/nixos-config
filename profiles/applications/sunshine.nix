{ config, lib, pkgs, ... }: {
  boot.kernelModules = [ "uinput" ];

  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660" OPTIONS+="static_node=uinput"
  '';

  environment.systemPackages = [ pkgs.sunshine ];

  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };

  systemd.user.services.sunshine = {
    description = "sunshine";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${config.security.wrapperDir}/sunshine";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      47984 47989 47990 48010
    ];
    allowedUDPPorts = [
      47998 47999 48000 48002 48010
    ];
  };

  persist.state.homeDirectories = [ ".config/sunshine" ];
}
