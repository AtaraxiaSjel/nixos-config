{ modulesPath, lib, inputs, pkgs, ... }: {
  imports = with inputs.self.nixosModules; with inputs.self.nixosProfiles; [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    inputs.self.nixosRoles.base
    inputs.base16.hmModule

    xray
    applications-setup
    sound
    themes

    firefox
    kitty
    mpv
    packages
    rofi
    vscode

    copyq
    cursor
    direnv
    fonts
    gtk
    kde
    mako
    nix-index
    print-scan
    proxy
    hyprland
    waybar


    # applications-setupsetup
    # cursor
    # fonts
    # gtk
    # i3status-rust
    # kde
    # kitty
    # mako
    # mpv
    # packages
    # print-scan
    # rofi
    # sound
    # sway
    # themes
    # vivaldi
    # vscode
    # kitty
    # mako
    # mpv
    # packages
    # print-scan
    # rofi
    # sound
    # sway
    # themes
    # vivaldi
    # vscode
  ];
  disabledModules = [ "installer/cd-dvd/channel.nix" ];
  networking.networkmanager.enable = lib.mkForce true;
  networking.wireless.enable = lib.mkForce false;
  services.getty.autologinUser = lib.mkForce "alukard";
  services.openssh.permitRootLogin = lib.mkForce "no";
  # sound.enable = lib.mkForce false;

  deviceSpecific.devInfo.drive.type = "hdd";
  deviceSpecific.devInfo.gpu.vendor = "other";
  deviceSpecific.isHost = false;
  deviceSpecific.isShared = false;
  deviceSpecific.isGaming = false;
  deviceSpecific.enableVirtualisation = false;
  deviceSpecific.wireguard.enable = false;
  deviceSpecific.isServer = false;

  isoImage.volumeID = lib.mkForce "NIXOS_ISO";
}