{ ... }: {
  boot.initrd = rec {
    # luks.devices = {
    #   "crypt-nas" = {
    #     device = "/dev/disk/by-id/usb-JMicron_Tech_A311737E-0:0";
    #     keyFile = "/nas_keyfile0.bin";
    #   };
    # };
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

  # boot.zfs.extraPools = [ "nas-pool" ];
}