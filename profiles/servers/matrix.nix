{ config, lib, pkgs, ... }: {
  virtualisation.libvirt.guests.fedora-synapse = {
    autoStart = true;
    user = config.mainuser;
    group = "libvirtd";
    uefi = true;
    memory = 2 * 1024;
    cpu = {
      sockets = 1; cores = 1; threads = 2;
    };
    devices = {
      disks = [ { diskFile = "/media/nas/libvirt/images/fedora-synapse.img"; type = "raw"; } ];
      network = {
        macAddress = "00:16:3e:5b:49:bf";
        interfaceType = "bridge";
        sourceDev = "br0";
      };
    };
  };
}