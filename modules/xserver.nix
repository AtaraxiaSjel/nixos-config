{ pkgs, lib, config, ... }:
with rec {
  inherit (config) deviceSpecific themes;
};
with deviceSpecific; with themes; {
  services.xserver = {
    enable = true;
    # enableTCP = true;

    libinput = {
      enable = isLaptop;
      # sendEventsMode = "disabled-on-external-mouse";
      # middleEmulation = false;
      accelProfile = lib.mkIf (!isLaptop) "flat";
      naturalScrolling = true;
    };

    # TODO: make settings for laptops with dGPU
    videoDrivers = if video == "amd" then
      [ "amdgpu" ]
    else if video == "nvidia" then
      [ "nvidia" ]
    else if video == "intel" then
      [ "intel" ]
    else
      [ ];

    displayManager.lightdm = {
      enable = true;
      greeter.enable = isShared;
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
            font = "Roboto Mono"
            font-size = 14pt
            text-color = "${colors.green}"
            error-color = "${colors.green}"
            background-image = ""
            background-color = "${colors.bg}"
            window-color = "${colors.dark}"
            border-color = "${colors.blue}"
            border-width = 1px
            layout-space = 14
            password-color = "${colors.green}"
            password-background-color = "${colors.bg}"
        '';
      };
      autoLogin.enable = !isShared;
      autoLogin.user = "alukard";
    };

    desktopManager.default = "none";
    desktopManager.xterm.enable = false;

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
    windowManager.default = "i3";

    layout = "us,ru";
    xkbOptions = "grp:win_space_toggle";
  };

  environment.systemPackages = if video == "amd" then
    [ (pkgs.mesa.override { enableRadv = true; }) ]
  else
    [ ];
}
