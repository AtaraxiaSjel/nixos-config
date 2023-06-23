{ config, ... }: {
systemd.services.libvirtd = {
    path = let
      env = pkgs.buildEnv {
        name = "qemu-hook-env";
        paths = with pkgs; [
          libvirt bash util-linux pciutils ripgrep
          procps coreutils systemd kmod gawk
        ];
      };
    in [ env ];
  };

  system.activationScripts.libvirt-hooks.text = ''
    ln -Tfs /etc/libvirt/hooks /var/lib/libvirt/hooks
    ln -Tfs /etc/libvirt/vgabios /var/lib/libvirt/vgabios
  '';

  environment.etc = {
    "libvirt/hooks/qemu".source = ./passthrough/qemu;
    "libvirt/hooks/qemu.d/win10/vfio-script.sh".source = ./passthrough/vfio-script.sh;
    "libvirt/vgabios/navi22.rom".source = ./passthrough/navi22.rom;
  };

  systemd.services.hyprland-logout = {
    script = "hyprctl dispatch exit";
    serviceConfig = {
      Type = "oneshot";
      User = config.mainuser;
    };
    path = [
      config.home-manager.users.${config.mainuser}.wayland.windowManager.hyprland.package
    ];
  };
}