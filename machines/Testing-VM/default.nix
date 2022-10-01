{ inputs, modulesPath, config, pkgs, lib, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    "${modulesPath}/profiles/qemu-guest.nix"
    ./qemu-vm.nix
    # ./hardware-configuration.nix
    inputs.self.nixosRoles.base
    inputs.base16.hmModule

    direnv
    firefox
    fonts
    themes
    vscode
  ];

  deviceSpecific.devInfo = {
    cpu = {
      vendor = "amd";
      clock = 3700;
      cores = 2;
    };
    drive = {
      type = "ssd";
      speed = 2000;
      size = 30;
    };
    gpu = {
      vendor = "other";
    };
    bigScreen = false;
    ram = 4;
  };
  deviceSpecific.isHost = true;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;
  deviceSpecific.wireguard.enable = false;

  hardware.video.hidpi.enable = lib.mkForce false;

  boot.kernelPackages = lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
  services.xserver = {
    # enable = false;
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };
  # services.greetd = {
  #   enable = true;
  #   package = pkgs.greetd.gtkgreet;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.cage}/bin/cage -s -- gtkgreet";
  #     };
  #   };
  # };
  # services.greetd = {
  #   enable = true;
  #   package = pkgs.greetd.tuigreet;
  #   settings = {
  #     default_session = {
  #       # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session \"${pkgs.plasma5Packages.plasma-workspace}/share/wayland-sessions\"";
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  #       # user = "alukard";
  #     };
  #   };
  # };
  networking.usePredictableInterfaceNames = lib.mkForce false;
  # environment.systemPackages = with pkgs; [ firefox ];
}
