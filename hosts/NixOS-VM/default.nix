{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  ataraxia.defaults.role = "base";

  boot.kernelParams = [
    "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
  ];

  virtualisation.memorySize = 4096;
  virtualisation.cores = 4;
  virtualisation.resolution.x = 1920;
  virtualisation.resolution.y = 1080;
  virtualisation.qemu.options = [
    "-vga qxl"
    "-display gtk"
  ];
  users.users.test = {
    isNormalUser = true;
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "84977205";

  environment.systemPackages = with pkgs; [
    # test overlay
    sing-box
  ];

  # Test persist module
  persist.enable = true;
  persist.cache.clean.enable = true;
  persist.state.directories = [ "/etc" ];
  persist.cache.directories = [ "/cache" ];
  home-manager.users.ataraxia = {
    home.stateVersion = "24.11";
    persist.enable = true;
    persist.cache.clean.enable = false;
    persist.state.directories = [ "test-home" ];
    persist.cache.directories = [
      "test-1"
      "test-2"
    ];
    persist.state.files = [ "home" ];
  };
  home-manager.users.test = {
    home.stateVersion = "24.11";
    persist.enable = true;
    persist.cache.clean.enable = true;
    persist.cache.directories = [
      "test-3"
      "test-4"
    ];
    persist.cache.files = [
      "home"
      "home3"
    ];
  };

  system.stateVersion = "24.11";
}
