{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  ataraxia.defaults.role = "base";

  # boot.kernelParams = [
  #   "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
  # ];

  virtualisation.memorySize = 4096;
  virtualisation.cores = 4;
  virtualisation.resolution.x = 1920;
  virtualisation.resolution.y = 1080;
  virtualisation.qemu.options = [
    "-vga qxl"
    "-display gtk"
  ];
  virtualisation.diskSize = 8192;

  boot.loader.grub.enable = false;

  ataraxia.virtualisation.podman = true;
  ataraxia.containers.filestash.enable = true;

  system.stateVersion = "25.05";
}
