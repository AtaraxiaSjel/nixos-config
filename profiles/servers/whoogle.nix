{ inputs, ... }: {
  imports = [ inputs.ataraxiasjel-nur.nixosModules.whoogle ];
  services.whoogle-search = {
    enable = true;
    listenAddress = "0.0.0.0";
    listenPort = 5000;
  };
  networking.firewall.allowedTCPPorts = [ 5000 ];
}