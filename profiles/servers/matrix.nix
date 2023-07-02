{ config, lib, pkgs, ... }: {
  virtualisation.libvirt.guests.arch-matrix = {
    user = config.mainuser;
    group = "libvirtd";
    # I need more ram... temporarily disabled
    autoStart = true;
    memory = 2 * 1024;
    cpu = {
      sockets = 1; cores = 1; threads = 1;
    };
    devices = {
      disks = [ { diskFile = "/media/nas/libvirt/images/matrix-server.qcow2"; } ];
      network = {
        macAddress = "00:16:3e:5b:49:bf";
        interfaceType = "bridge";
        sourceDev = "br0";
      };
    };
  };
}