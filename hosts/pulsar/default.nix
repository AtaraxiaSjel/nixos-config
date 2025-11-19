{
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    ./minimal.nix
    ./server.nix

    ./matrix.nix
    ./tuwunel.nix # Remove after 25.11 release

    inputs.srvos.nixosModules.common
    inputs.srvos.nixosModules.mixins-nix-experimental
    inputs.srvos.nixosModules.mixins-trusted-nix-caches
    (modulesPath + "/virtualisation/lxc-container.nix")
  ];

  ataraxia.defaults.role = "container";
  ataraxia.networkd = {
    enable = true;
    disableIPv6 = true;
    domain = "matrix.ataraxiadev.com";
    bridge.enable = false;
    ifname = [
      "en*"
      "eth*"
    ];
    ipv4 = [
      {
        address = "10.10.10.21/24";
        gateway = "10.10.10.1";
        dns = [ "10.10.10.9" ];
      }
    ];
  };
  srvos.registerSelf = false;
  srvos.update-diff.enable = false;
  environment = {
    systemPackages = [ pkgs.nano ];
    variables.EDITOR = lib.getExe pkgs.nano;
  };

  systemd.enableStrictShellChecks = true;
  services.journald.storage = "volatile";
  services.journald.extraConfig = ''
    SystemMaxUse=8M
    Compress=yes
  '';

  users.users.root.initialHashedPassword = "$y$j9T$jpOuNmz7hPJPWPyT05FAZ/$0iFlDbkW4IetmbTWkq0/cdnXkQ.JDBDZgzz52sueLt3";
  ### deploy-rs support ###
  users.users.deploy = {
    isNormalUser = true;
    description = "System deploy user";
    uid = 2000;
    extraGroups = [
      "wheel"
      "sudo"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+xd8ClJPvJuAdYC9HlNnjiubEtYfvnKjYr9ROV+UmPVvI3ZITF24OaMI+fxgR0EqGfcUzSGom8528IB53Q3aFMIAaA0vKjW+jrByyB2l/k/+ttpLbH75c9WyOpAcUDTen8BhHKPyXOHoJ1jLu7GFmtPZ+mZo8thFB/VIRrwECHd8DnF0drsSCorkRp1bZC7bAHgztaYHNBUoAVGgJ7nLwW7DotlgbUEDiPJHXOxd/c/ZlXIB/cfUUqF+L5ThbMPhMcwRMspLy+nQdmHhih9k6SkvYqJoNqHT5/XeShb0RkIzvUWT2CYTPop5kAY5mMnatVTOY1FZPhHzk3G8MhOQ3r/elM/ecZxmjL8uozMN9kRGf1IL4DgQZfVqQRILdNSQGb0tfeiyirNZe1RlDw9UvMnZJOw0EkiC9lSSRhBWXXxAmxRrbNFTPQSp+/kiIGDmp2AsGhD11CfTDEU3wcLEUPBUqp1FYSzHncJyEKGy2Dpa5xaUJ0cuyGL4W3WHDXa4sTfY+AIXbQTD88Ujdsbfzyd6lrikG4D/crCurXissrh7q9DuYKWRI24cp5bw9lG33U1EXisnZqFyZNwMAmSj2QEGsHCwSevn0FgyRa2WYXgpZ9hfgY4le+ZSMo2JTosQ6DjGyxMDyQAHJ/ismTTzL67Q2p6U+73toYm62Qqdspw== (none)"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP0/DReYSAfkucroMTdELzTORsGhhbEa+W0FDFBnwViHuoqoKvetCOkW657icexc5v/j6Ghy3+Li9twbHnEDzUJVtNtauhGMjOcUYt6pTbeJ09CGSAh+orxzeY4vXp7ANb91xW8yRn/EE4ALxqbLsc/D7TUMl11fmf0UW+kLgU5TcUYVSLMjQqBpD1Lo7lXLrImloDxe5fwoBDT09E59r9tq6+/3aHz8mpKRLsIQIV0Av00BRJ+/OVmZuBd9WS35rfkpUYmpEVInSJy3G4O6kCvY/zc9Bnh67l4kALZZ0+6W23kBGrzaRfaOtCEcscwfIu+6GXiHOL33rrMNNinF0T2942jGc18feL6P/LZCzqz8bGdFNxT43jAGPeDDcrJEWAJZFO3vVTP65dTRTHQG2KlQMzS7tcif6YUlY2JLJIb61ZfLoShH/ini/tqsGT0Be1f3ndOFt48h4XMW1oIF+EXaHYeO2UJ6855m8Wpxs4bP/jX6vMV38IvvnHy4tWD50= alukard@AMD-Workstation"
    ];
  };
  nix.settings.trusted-users = [ "deploy" ];
  services.openssh.enable = true;
  services.openssh.settings.AllowUsers = [ "deploy" ];
  security.pam.sshAgentAuth.enable = true;
  security.sudo.enable = false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = lib.mkForce false;
    extraRules = [
      {
        users = [ "deploy" ];
        commands = [
          {
            command = "/nix/store/*-activatable-nixos-system-*/activate-rs";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
          {
            command = "/run/current-system/sw/bin/rm /tmp/deploy-rs-canary-*";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
        ];
      }
    ];
  };
  ### END ###

  system.stateVersion = "25.05";
}
