{ pkgs, config, ... }:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.samsung-unified-linux-driver pkgs.gutenprint ];
  };

  hardware.sane.enable = true;
  services.saned.enable = true;

  home-manager.users.${config.mainuser}.home.packages = [
    pkgs.system-config-printer
  ];

  environment.systemPackages = [ pkgs.simple-scan ];
}
