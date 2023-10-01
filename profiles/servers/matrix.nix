{ config, lib, pkgs, ... }: {
  virtualisation.libvirt.guests.fedora-synapse = {
    autoStart = false;
    user = config.mainuser;
    group = "libvirtd";
    uefi = true;
    memory = 2 * 1024;
    cpu = {
      sockets = 1; cores = 1; threads = 2;
    };
    devices = {
      disks = [
        { diskFile = "/media/nas/libvirt/images/fedora-matrix-root.img"; type = "raw"; targetName = "vda"; }
        { diskFile = "/media/nas/libvirt/images/fedora-matrix-synapse.img"; type = "raw"; targetName = "vdb"; }
      ];
      network = {
        macAddress = "00:16:3e:5b:49:bf";
        interfaceType = "bridge";
        sourceDev = "br0";
      };
    };
  };
}