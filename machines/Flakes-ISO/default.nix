{ modulesPath, lib, inputs, pkgs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.self.nixosRoles.base
    inputs.base16.hmModule

    applications-setup
    cursor
    fonts
    gtk
    i3status-rust
    kde
    kitty
    mako
    mpv
    packages
    picom
    print-scan
    rofi
    sound
    sway
    themes
    vivaldi
    vscode
  ];
  disabledModules = [ "installer/cd-dvd/channel.nix" ];
  hardware.pulseaudio.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce true;
  networking.wireless.enable = lib.mkForce false;
  services.getty.autologinUser = lib.mkForce "alukard";
  services.openssh.permitRootLogin = lib.mkForce "no";
  sound.enable = lib.mkForce false;

  deviceSpecific.devInfo.drive.type = "hdd";
  deviceSpecific.devInfo.gpu.vendor = "other";
  deviceSpecific.isHost = false;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;
  deviceSpecific.wireguard.enable = false;
}