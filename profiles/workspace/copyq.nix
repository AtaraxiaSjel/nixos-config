{ config, pkgs, ... }: {
  environment.systemPackages = [ pkgs.copyq ];
  home-manager.users.${config.mainuser} = {
    wayland.windowManager.hyprland.extraConfig = ''
      windowrule=float,title=(.*CopyQ)
    '';
    # command = "move position mouse";
  };
  startupApplications = [ "${pkgs.copyq}/bin/copyq" ];
  persist.state.homeDirectories = [ ".config/copyq" ];
}