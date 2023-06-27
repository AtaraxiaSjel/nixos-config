{ config, pkgs, lib, ... }: {
  security.apparmor.enable = true;
  programs.firejail.enable = true;

  users.mutableUsers = false;
  users.users.${config.mainuser} = {
    isNormalUser = true;
    extraGroups = [
      "adbusers"
      "audio"
      "cdrom"
      "corectrl"
      "dialout"
      "disk"
      "docker"
      "input"
      "kvm"
      "libvirtd"
      "lp"
      "lxd"
      "networkmanager"
      "podman"
      "qemu-libvirtd"
      "render"
      "scanner"
      "systemd-journal"
      "smbuser"
      "video"
      # "wheel" # remove?
    ];
    description = "AtaraxiaDev";
    uid = 1000;
    hashedPassword = "$y$j9T$ZC44T3XYOPapB26cyPsA4.$8wlYEbwXFszC9nrg0vafqBZFLMPabXdhnzlT3DhUit6";

    shell = pkgs.zsh;
  };
  users.users.deploy = {
    description = "The administrator account for deploy-rs.";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys =
      config.users.users.${config.mainuser}.openssh.authorizedKeys.keys;
  };
  programs.zsh.enable = true;
  # Safe, because we using doas
  users.allowNoPasswordLogin = true;

  systemd.services."user@" = { serviceConfig = { Restart = "always"; }; };
  services.getty.autologinUser = config.mainuser;
}
