{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  virtualisation.memorySize = 4096;
  virtualisation.cores = 4;
  virtualisation.resolution.x = 1920;
  virtualisation.resolution.y = 1080;
  virtualisation.qemu.options = [
    "-vga qxl"
    "-display gtk"
  ];

  users.mutableUsers = false;
  users.users.ataraxia = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$ZC44T3XYOPapB26cyPsA4.$8wlYEbwXFszC9nrg0vafqBZFLMPabXdhnzlT3DhUit6";
    shell = pkgs.bash;
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "84977205";

  system.stateVersion = "24.11";
}
