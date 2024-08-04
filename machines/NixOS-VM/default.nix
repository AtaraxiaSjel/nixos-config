{ modulesPath, self, inputs, config, pkgs, ... }: {
  disabledModules = [ "${self}/modules/pass-store.nix" ];
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"

    ../AMD-Workstation/kernel

    inputs.self.customModules.devices
    inputs.self.customProfiles.ccache
    inputs.self.customModules.users
    inputs.nixos-cosmic.nixosModules.default
  ];

  virtualisation.memorySize = 4096;
  virtualisation.cores = 4;
  virtualisation.resolution.x = 1920;
  virtualisation.resolution.y = 1080;
  virtualisation.qemu.options = ["-vga none" "-device virtio-vga-gl" "-display gtk,gl=on"];

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  users.mutableUsers = false;
  users.users.${config.mainuser} = {
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