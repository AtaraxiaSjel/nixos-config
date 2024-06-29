{ config, pkgs, lib, inputs, ... }: {
  imports = with inputs.self; [
    customProfiles.virtualisation
  ];
  deviceSpecific.enableVirtualisation = true;

  boot.kernelModules = [ "x_tables" ];

  virtualisation = {
    docker.enable = lib.mkForce false;
    podman.defaultNetwork.settings.dns_enabled = lib.mkForce false;
    podman.extraPackages = [ pkgs.zfs ];
    spiceUSBRedirection.enable = lib.mkForce false;
    containers.storage.settings.storage.graphroot = lib.mkForce  "/var/lib/podman/storage";
  };

  users.users.${config.mainuser} = {
    subUidRanges = [{
      count = 1000;
      startUid = 10000;
    }];
    subGidRanges = [{
      count = 1000;
      startGid = 10000;
    }];
  };
}