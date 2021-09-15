{ pkgs, lib, config, ... }: {

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    forwardX11 = true;
    extraConfig = "StreamLocalBindUnlink yes";
    ports = [ 22 ];
  };

  home-manager.users.alukard = {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          compression = false;
        };
      };
    };
  };
}
