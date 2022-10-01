{ modulesPath, config, ... }: {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];
  virtualisation = {
    qemu.options = [ "-vga none" "-device virtio-vga-gl" "-display gtk,gl=on" ];
    cores = 4;
    memorySize = 4096;
    #msize = 262144;
    diskSize = 10240;
    diskImage = "./vm-images/${config.device}.qcow2";
    # resolution = { x = 1920; y = 1080; };

    useNixStoreImage = true;
    writableStore = false;
  };
}