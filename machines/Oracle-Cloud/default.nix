{ inputs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.desktop
  ];

  deviceSpecific.devInfo = {
    cpu = {
      arch = "aarch64";
      vendor = "broadcom";
      clock = 2800;
      cores = 2;
    };
    drive = {
      type = "ssd";
      speed = 1000;
      size = 100;
    };
    gpu = {
      vendor = "other";
    };
    bigScreen = false;
    ram = 12;
  };
  deviceSpecific.isHost = false;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;
  deviceSpecific.wireguard.enable = false;

  boot.cleanTmpDir = true;
  networking.hostName = "matrix-vm-instance";
  networking.firewall.allowPing = true;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1OdiD3T30dTTVtwDjiVEQ+Dd9P92/4rI60x1xYtr6P75UYZF7eIO6FrxH8FAeSH6N10YsdTK1NPRDj5bsbLDB7d4D4YewPw+tnl3Qnp/04k+/+gpSFhVyUwKWvSTgU34NZFiwdHLuefYkHdAmDBhUhWC+28DyWSPn2LLTHhGRBOaNG39ur/1vaIuJb00vbzA/HWQmIYIByd51gjQkgC+SxIlYb13Q/L6SqHCZ8RUzJyS9bGM9Imw5T7V7SVC2FRjOt6NUm8AVVw06yRgtjXipEYA9GE+Rp69+MNmKr2OxR//KWyQb/SCfQyIWrBn0ee266XukOFuC4bpp50TjTEXx oracle_cloud"
  ];
}
