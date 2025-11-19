# Stripped down server profile from srvos
{
  config,
  lib,
  options,
  ...
}:
{
  environment = {
    variables.BROWSER = "echo";
    stub-ld.enable = lib.mkDefault false;
  };
  security.sudo.wheelNeedsPassword = false;
  # Prevent LLMNR poisoning attacks
  services.resolved.llmnr = lib.mkDefault "false";
  time.timeZone = lib.mkDefault "UTC";
  # Given that our systems are headless, emergency mode is useless.
  # We prefer the system to attempt to continue booting so
  # that we can hopefully still access it remotely.
  boot.initrd.systemd.suppressedUnits = lib.mkIf config.systemd.enableEmergencyMode [
    "emergency.service"
    "emergency.target"
  ];
  systemd = {
    enableEmergencyMode = false;
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  }
  // (
    # TODO: remove when 25.05 is deprecated
    if options.systemd ? settings then
      {
        settings.Manager = {
          RuntimeWatchdogSec = lib.mkDefault "15s";
          RebootWatchdogSec = lib.mkDefault "30s";
          KExecWatchdogSec = lib.mkDefault "1m";
        };
      }
    else
      {
        watchdog = {
          runtimeTime = lib.mkDefault "15s";
          rebootTime = lib.mkDefault "30s";
          kexecTime = lib.mkDefault "1m";
        };
      }
  );

  # Make sure the serial console is visible in qemu when testing the server configuration
  # with nixos-rebuild build-vm
  virtualisation.vmVariant.virtualisation.graphics = lib.mkDefault false;
}
