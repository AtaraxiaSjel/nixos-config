{ pkgs, ... }: {
  boot.initrd = rec {
    luks.devices = {
      "crypt-nas" = {
        device = "/dev/disk/by-id/ata-ST4000NM0035-1V4107_ZC1A7CWN";
        keyFile = "/nas_keyfile0.bin";
      };
    };
    secrets = {
      "nas_keyfile0.bin" = "/etc/secrets/nas_keyfile0.bin";
    };
    availableKernelModules = [
      "usb_storage"
      "usbcore"
      "scsi_mod"
      "usb_common"
      "ehci_pci" "ahci" "uas" "sd_mod" "sdhci_pci"
    ];
    kernelModules = availableKernelModules;
  };

  boot.zfs.extraPools = [ "nas-pool" ];

  system.activationScripts.disable-hdd-spindown.text = ''
    ${pkgs.hdparm}/bin/hdparm -s 0 /dev/disk/by-id/ata-ST4000NM0035-1V4107_ZC1A7CWN
  '';
}