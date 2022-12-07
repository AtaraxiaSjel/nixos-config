{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
    "${toString modulesPath}/virtualisation/qemu-vm.nix"
  ];
  virtualisation = {
    qemu.options = [ "-vga none" "-device virtio-vga-gl" "-display gtk,gl=on" ];
    cores = 1;
    memorySize = 4096;
    msize = 65536;
    diskSize = 10240;
    diskImage = "/media/libvirt/vm-images/${config.device}.qcow2";
    # resolution = { x = 1920; y = 1080; };
    # useNixStoreImage = true;
    # writableStore = false;
    # writableStore = true;
    # useNixStoreImage = true;
    # writableStoreUseTmpfs = true;
  };
  # services.spice-vdagentd.enable = lib.mkOverride 0 true;
  # services.xserver.videoDrivers = [ "qxl" ];
  # services.qemuGuest.enable = true;
}
