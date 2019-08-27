{ pkgs, lib, config, ... }:
let
  cpu = config.deviceSpecific.cpu;
  isShared = config.deviceSpecific.isShared;
  defaultUser = config.user.defaultUser;
in {
  services.xserver = {
    enable = true;
    # enableTCP = true;

    libinput = {
      enable = true;
      sendEventsMode = "disabled-on-external-mouse";
      middleEmulation = false;
      # naturalScrolling = true;
    };

    videoDrivers = if cpu == "amd" then
      ["amdgpu"]
    else if cpu == "intel" then
      ["intel"]
    else
      [ ];

    displayManager.lightdm = {
      enable = true;
      greeter.enable = isShared;
      autoLogin.enable = !isShared;
      autoLogin.user = "alukard";
      # autoLogin.user = defaultUser;
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

  environment.systemPackages = if cpu == "amd" then
    [ (pkgs.mesa.override { enableRadv = true; }) ]
  else
    [ ];
}
