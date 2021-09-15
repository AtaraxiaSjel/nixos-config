{ pkgs, lib, config, ... }:
let
  thm = config.lib.base16.theme;
in
with config.deviceSpecific; {
  services.xserver = {
    enable = true;

    # TODO: Disable natural scrolling for external mouse
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
        middleEmulation = false;
        naturalScrolling = false;
      };
      touchpad = lib.mkIf isLaptop {
        accelProfile = "adaptive";
        middleEmulation = true;
        naturalScrolling = true;
      };
    };

    # TODO: make settings for laptops with dGPU
    videoDrivers = if devInfo.gpu.vendor == "amd" then
      [ "amdgpu" ]
    else if devInfo.gpu.vendor == "nvidia" then
      [ "nvidia" ]
    else if devInfo.gpu.vendor == "intel" then
      [ "intel" ]
    else
      [ ];

    displayManager.lightdm = {
      greeters.mini = {
        enable = isShared;
        user = "alukard";
        extraConfig = ''
          [greeter]
          show-password-label = true
          password-label-text = Welcome, Alukard
          invalid-password-text = Are you sure?
          show-input-cursor = false
          password-alignment = right
          [greeter-theme]
          font = "#${thm.font} Mono"
          font-size = 14pt
          text-color = "#${thm.base0B-hex}"
          error-color = "#${thm.base0B-hex}"
          background-image = ""
          background-color = "#${thm.base00-hex}"
          window-color = "#${thm.base01-hex}"
          border-color = "#${thm.base0D-hex}"
          border-width = 1px
          layout-space = 14
          password-color = "#${thm.base0B-hex}"
          password-background-color = "#${thm.base00-hex}"
        '';
      };
    };

    displayManager.autoLogin.enable = !isShared;
    displayManager.autoLogin.user = "alukard";

    displayManager.defaultSession = "none+i3";

    desktopManager.xterm.enable = false;

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };

    layout = "us,ru";
    xkbOptions = "grp:win_space_toggle";
  };
}
