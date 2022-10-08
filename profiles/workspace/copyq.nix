{ config, pkgs, ... }: {
  environment.systemPackages = [ pkgs.copyq ];
  home-manager.users.alukard = {
    wayland.windowManager.hyprland.extraConfig = ''
      windowrule=float,title=(.*CopyQ)
    '';
    # command = "move position mouse";
  };
  startupApplications = [ "${pkgs.copyq}/bin/copyq" ];
}