{ config, pkgs, lib, ... }:
with config.deviceSpecific; {
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
      "adbusers"
      "input"
      "libvirtd"
      "kvm"
      "vboxusers"
      "smbuser"
      "cdrom"
      "scanner"
      "lp"
      "dialout"
      "corectrl"
      "video"
    ];
    description = "Дмитрий Холкин";
    uid = 1000;
    hashedPassword = "$6$kDBGyd99tto$9LjQwixa7NYB9Kaey002MD94zHob1MmNbVz9kx3yX6Q4AmVgsFMGUyNuHozXprxyuXHIbOlTcf8nd4rK8MWfI/";
    shell = pkgs.zsh;
  };
  security.sudo = {
    enable = true;
    extraConfig = lib.concatStrings [''
      alukard ALL = (root) NOPASSWD: /run/current-system/sw/bin/btrfs fi usage /
    ''
    (if (isLaptop) then ''
      alukard ALL = (root) NOPASSWD: /run/current-system/sw/bin/tlp-stat
      alukard ALL = (root) NOPASSWD: /run/current-system/sw/bin/tlp ac
      alukard ALL = (root) NOPASSWD: /run/current-system/sw/bin/tlp bat
    '' else "")
    ];
  };
  home-manager.users.alukard = {
    systemd.user.services.polkit-agent = {
      Unit = {
        Description = "Run polkit authentication agent";
        X-RestartIfChanged = true;
      };
      Install.WantedBy = [ "sway-session.target" ];
      Service = { ExecStart = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1"; };
    };
  };
  home-manager.useUserPackages = true;
  systemd.services."user@" = { serviceConfig = { Restart = "always"; }; };
  services.getty.autologinUser = "alukard";
}
