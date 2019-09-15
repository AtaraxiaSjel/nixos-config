{ pkgs, lib, config, ... }:
with rec {
  inherit (config) deviceSpecific;
};
with deviceSpecific; {
  services.xserver = {
    enable = true;
    # enableTCP = true;

    libinput = {
      enable = isLaptop;
      sendEventsMode = "disabled-on-external-mouse";
      middleEmulation = false;
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
      autoLogin.enable = !isShared;
      autoLogin.user = "alukard";
    };

    # desktopManager.plasma5.enable = true;
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
