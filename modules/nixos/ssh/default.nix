{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption;
  inherit (lib.types) listOf int;
  cfg = config.ataraxia.defaults.ssh;
in
{
  options.ataraxia.defaults.ssh = {
    enable = mkEnableOption "Root on zfs";
    ports = mkOption {
      type = listOf int;
      default = [ 22 ];
      description = "OpenSSH ports to listen";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "no";
      settings.X11Forwarding = false;
      extraConfig = "StreamLocalBindUnlink yes";
      ports = cfg.ports;
    };
  };
}
