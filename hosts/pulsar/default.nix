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
  services.openssh.enable = true;
  security.pam.sshAgentAuth.enable = true;
  ### END ###

  system.stateVersion = "25.05";
}
