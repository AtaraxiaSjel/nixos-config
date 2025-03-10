{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkOption;
  inherit (lib.types) str;
  cfg = config.ataraxia.defaults.users;
in
{
  options.ataraxia.defaults.users = {
    enable = mkEnableOption "Setting up default users";
    defaultUser = mkOption {
      type = str;
      default = "ataraxia";
      description = "Name of the default user";
    };
  };

  config = mkIf cfg.enable {
    users.mutableUsers = false;
    users.groups.limits = { };
    users.users.${cfg.defaultUser} = {
      description = "Main user of this host.";
      isNormalUser = true;
      extraGroups = [
        "adbusers"
        "audio"
        "cdrom"
        "corectrl"
        "dialout"
        "disk"
        "docker"
        "input"
        "kvm"
        "libvirtd"
        "limits"
        "lp"
        "lxd"
        "networkmanager"
        "podman"
        "qemu-libvirtd"
        "render"
        "scanner"
        "smbuser"
        "systemd-journal"
        "video"
        "wheel"
      ];
      uid = 1000;
      hashedPassword = "$y$j9T$ZC44T3XYOPapB26cyPsA4.$8wlYEbwXFszC9nrg0vafqBZFLMPabXdhnzlT3DhUit6";
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+xd8ClJPvJuAdYC9HlNnjiubEtYfvnKjYr9ROV+UmPVvI3ZITF24OaMI+fxgR0EqGfcUzSGom8528IB53Q3aFMIAaA0vKjW+jrByyB2l/k/+ttpLbH75c9WyOpAcUDTen8BhHKPyXOHoJ1jLu7GFmtPZ+mZo8thFB/VIRrwECHd8DnF0drsSCorkRp1bZC7bAHgztaYHNBUoAVGgJ7nLwW7DotlgbUEDiPJHXOxd/c/ZlXIB/cfUUqF+L5ThbMPhMcwRMspLy+nQdmHhih9k6SkvYqJoNqHT5/XeShb0RkIzvUWT2CYTPop5kAY5mMnatVTOY1FZPhHzk3G8MhOQ3r/elM/ecZxmjL8uozMN9kRGf1IL4DgQZfVqQRILdNSQGb0tfeiyirNZe1RlDw9UvMnZJOw0EkiC9lSSRhBWXXxAmxRrbNFTPQSp+/kiIGDmp2AsGhD11CfTDEU3wcLEUPBUqp1FYSzHncJyEKGy2Dpa5xaUJ0cuyGL4W3WHDXa4sTfY+AIXbQTD88Ujdsbfzyd6lrikG4D/crCurXissrh7q9DuYKWRI24cp5bw9lG33U1EXisnZqFyZNwMAmSj2QEGsHCwSevn0FgyRa2WYXgpZ9hfgY4le+ZSMo2JTosQ6DjGyxMDyQAHJ/ismTTzL67Q2p6U+73toYm62Qqdspw== (none)"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP0/DReYSAfkucroMTdELzTORsGhhbEa+W0FDFBnwViHuoqoKvetCOkW657icexc5v/j6Ghy3+Li9twbHnEDzUJVtNtauhGMjOcUYt6pTbeJ09CGSAh+orxzeY4vXp7ANb91xW8yRn/EE4ALxqbLsc/D7TUMl11fmf0UW+kLgU5TcUYVSLMjQqBpD1Lo7lXLrImloDxe5fwoBDT09E59r9tq6+/3aHz8mpKRLsIQIV0Av00BRJ+/OVmZuBd9WS35rfkpUYmpEVInSJy3G4O6kCvY/zc9Bnh67l4kALZZ0+6W23kBGrzaRfaOtCEcscwfIu+6GXiHOL33rrMNNinF0T2942jGc18feL6P/LZCzqz8bGdFNxT43jAGPeDDcrJEWAJZFO3vVTP65dTRTHQG2KlQMzS7tcif6YUlY2JLJIb61ZfLoShH/ini/tqsGT0Be1f3ndOFt48h4XMW1oIF+EXaHYeO2UJ6855m8Wpxs4bP/jX6vMV38IvvnHy4tWD50= alukard@AMD-Workstation"
      ];
    };
    users.users.deploy = {
      description = "The administrator account for deploy-rs.";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = config.users.users.${cfg.defaultUser}.openssh.authorizedKeys.keys;
    };

    security.apparmor.enable = true;
    security.pam.loginLimits = [
      {
        domain = "@limits";
        item = "memlock";
        type = "soft";
        value = "unlimited";
      }
      {
        domain = "@limits";
        item = "memlock";
        type = "hard";
        value = "unlimited";
      }
    ];
    security.polkit.enable = true;
    systemd.services."user@" = {
      serviceConfig = {
        Restart = "always";
      };
    };

    # Disable sudo, use doas
    users.allowNoPasswordLogin = true;
    security.sudo.enable = lib.mkForce false;
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [ cfg.defaultUser ];
          keepEnv = true;
          persist = true;
        }
        {
          users = [ "deploy" ];
          noPass = true;
          keepEnv = true;
        }
      ];
    };
  };
}
