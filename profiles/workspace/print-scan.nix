{ pkgs, config, ... }:
{
  services.printing = {
    enable = true;
    drivers = [ pkgs.samsung-unified-linux-driver pkgs.gutenprint ];
  };

  hardware.sane.enable = true;
  services.saned.enable = true;

  environment.systemPackages = [ pkgs.gnome.simple-scan ];
}
