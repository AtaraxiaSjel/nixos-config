{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.theme) colors fonts;

  cfg = config.ataraxia.wayland.wlogout;
in
{
  options.ataraxia.wayland.wlogout = {
    enable = mkEnableOption "Enable wlogout";
  };

  config = mkIf cfg.enable {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "";
          text = "Lock";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
        }
        {
          label = "logout";
          action = "hyprctl dispatch exit 0";
          text = "Logout";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
        }
      ];
      style = mkIf (!config.catppuccin.wlogout.enable) ''
        window {
          font-family: "${fonts.mono.family}";
          font-size: 18pt;
          color: ${colors.color5};
          background-color: alpha(${colors.color0}, 0.8);
        }
        button {
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          border: none;
          background-color: alpha(${colors.color0}, 0);
          color: ${colors.color14};
        }
        button:hover {
          background-color: alpha(${colors.color2}, 0.1);
        }
        button:focus {
          background-color: ${colors.color14};
          color: ${colors.color0};
        }
        #lock {
          background-image: image(url("${./lock.png}"));
          padding: 35px;
        }
        #lock:focus {
          background-image: image(url("${./lock-hover.png}"));
          padding: 35px;
        }
        #logout {
          background-image: image(url("${./logout.png}"));
          padding: 30px;
        }
        #logout:focus {
          background-image: image(url("${./logout-hover.png}"));
          padding: 30px;
        }
        #suspend {
          background-image: image(url("${./sleep.png}"));
          padding: 30px;
        }
        #suspend:focus {
          background-image: image(url("${./sleep-hover.png}"));
          padding: 30px;
        }
        #shutdown {
          background-image: image(url("${./power.png}"));
          padding: 30px;
        }
        #shutdown:focus {
          background-image: image(url("${./power-hover.png}"));
          padding: 30px;
        }
        #reboot {
          background-image: image(url("${./restart.png}"));
          padding: 30px;
        }
        #reboot:focus {
          background-image: image(url("${./restart-hover.png}"));
          padding: 30px;
        }
      '';
    };
    catppuccin.wlogout = {
      iconStyle = "wlogout";
      extraStyle = ''
        window {
          font-family: "${fonts.mono.family}";
          font-size: 18pt;
        }
      '';
    };
  };
}
