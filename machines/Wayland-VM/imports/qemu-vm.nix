{ modulesPath, config, ... }: {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];
  virtualisation = {
    qemu.options = [ "-vga none" "-device virtio-vga-gl" "-display gtk,gl=on" ];
    cores = 4;
    memorySize = 6044;
    msize = 131072;
    diskSize = 20480;
    diskImage = "/media/libvirt/vm-images/${config.device}.qcow2";
    # resolution = { x = 1920; y = 1080; };

    useNixStoreImage = true;
    writableStore = false;
  };
}
