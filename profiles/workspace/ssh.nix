{ pkgs, lib, config, ... }: {

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    forwardX11 = true;
    extraConfig = "StreamLocalBindUnlink yes";
    ports = [ 22 ];
  };

  users.users.alukard.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+xd8ClJPvJuAdYC9HlNnjiubEtYfvnKjYr9ROV+UmPVvI3ZITF24OaMI+fxgR0EqGfcUzSGom8528IB53Q3aFMIAaA0vKjW+jrByyB2l/k/+ttpLbH75c9WyOpAcUDTen8BhHKPyXOHoJ1jLu7GFmtPZ+mZo8thFB/VIRrwECHd8DnF0drsSCorkRp1bZC7bAHgztaYHNBUoAVGgJ7nLwW7DotlgbUEDiPJHXOxd/c/ZlXIB/cfUUqF+L5ThbMPhMcwRMspLy+nQdmHhih9k6SkvYqJoNqHT5/XeShb0RkIzvUWT2CYTPop5kAY5mMnatVTOY1FZPhHzk3G8MhOQ3r/elM/ecZxmjL8uozMN9kRGf1IL4DgQZfVqQRILdNSQGb0tfeiyirNZe1RlDw9UvMnZJOw0EkiC9lSSRhBWXXxAmxRrbNFTPQSp+/kiIGDmp2AsGhD11CfTDEU3wcLEUPBUqp1FYSzHncJyEKGy2Dpa5xaUJ0cuyGL4W3WHDXa4sTfY+AIXbQTD88Ujdsbfzyd6lrikG4D/crCurXissrh7q9DuYKWRI24cp5bw9lG33U1EXisnZqFyZNwMAmSj2QEGsHCwSevn0FgyRa2WYXgpZ9hfgY4le+ZSMo2JTosQ6DjGyxMDyQAHJ/ismTTzL67Q2p6U+73toYm62Qqdspw== (none)"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1OdiD3T30dTTVtwDjiVEQ+Dd9P92/4rI60x1xYtr6P75UYZF7eIO6FrxH8FAeSH6N10YsdTK1NPRDj5bsbLDB7d4D4YewPw+tnl3Qnp/04k+/+gpSFhVyUwKWvSTgU34NZFiwdHLuefYkHdAmDBhUhWC+28DyWSPn2LLTHhGRBOaNG39ur/1vaIuJb00vbzA/HWQmIYIByd51gjQkgC+SxIlYb13Q/L6SqHCZ8RUzJyS9bGM9Imw5T7V7SVC2FRjOt6NUm8AVVw06yRgtjXipEYA9GE+Rp69+MNmKr2OxR//KWyQb/SCfQyIWrBn0ee266XukOFuC4bpp50TjTEXx oracle_cloud"
  ];

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
