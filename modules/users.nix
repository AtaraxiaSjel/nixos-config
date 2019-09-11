{ config, pkgs, lib, ... }: {
  # users.defaultUser = "alukard";

  security.apparmor.enable = true;
  programs.firejail.enable = true;
  users.mutableUsers = false;
  users.users.alukard = {
    isNormalUser = true;
    extraGroups = [
      "sudo"
      "wheel"
      "networkmanager"
      "disk"
      "dbus"
      "audio"
      "docker"
      "sound"
      "pulse"
      # "adbusers"
      "input"
      # "libvirtd"
      "vboxusers"
      # "wireshark"
    ];
    description = "Дмитрий Холкин";
    uid = 1000;
    hashedPassword = "$6$kDBGyd99tto$9LjQwixa7NYB9Kaey002MD94zHob1MmNbVz9kx3yX6Q4AmVgsFMGUyNuHozXprxyuXHIbOlTcf8nd4rK8MWfI/";
    shell = pkgs.zsh;
  };
  # security.sudo = {
  #   enable = true;
  #   extraConfig = ''
  #     alukard ALL = (root) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild switch
  #   '';
  # };
  # nix.requireSignedBinaryCaches = false;

  home-manager.useUserPackages = true;
}
