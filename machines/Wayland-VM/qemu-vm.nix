{ modulesPath, ... }: {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];
  virtualisation = {
    qemu.options = ["-vga none" "-device virtio-vga-gl" "-display gtk,gl=on"];
    cores = 4;
    memorySize = 4096;
    diskSize = 20480;
  };
}