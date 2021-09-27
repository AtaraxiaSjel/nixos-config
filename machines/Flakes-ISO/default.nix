{ modulesPath, lib, inputs, pkgs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.self.nixosRoles.base
    inputs.base16.hmModule

    alacritty
    cursor
    dunst
    fonts
    gtk
    i3
    i3status-rust
    rofi
    themes
    urxvt
    vivaldi
    vscode
    xserver
  ];
  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce true;
  services.openssh.permitRootLogin = lib.mkForce "no";
  sound.enable = lib.mkForce true;
  hardware.pulseaudio.enable = lib.mkForce true;
  services.getty.autologinUser = lib.mkForce "alukard";
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.supportedFilesystems = lib.mkForce [ "ext4" "vfat" "btrfs" "ntfs" ];
  disabledModules = [ "installer/cd-dvd/channel.nix" ];

  deviceSpecific.devInfo.drive.type = "hdd";
  deviceSpecific.devInfo.gpu.vendor = "other";
  deviceSpecific.isHost = false;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;
  deviceSpecific.wireguard.enable = false;

  defaultApplications = {
    fm = {
      cmd = "${pkgs.xfce4-14.thunar}/bin/thunar";
      desktop = "thunar";
    };
    monitor = {
      cmd = "${pkgs.xfce4-14.xfce4-taskmanager}/bin/xfce4-taskmanager";
      desktop = "taskmanager";
    };
  };
}