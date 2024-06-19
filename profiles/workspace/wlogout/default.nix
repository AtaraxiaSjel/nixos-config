{ config, lib, ... }: {
  home-manager.users.${config.mainuser} = let
    inherit (config.home-manager.users.${config.mainuser}.catppuccin) sources flavor accent;

    thm = config.lib.base16.theme;
    palette = (lib.importJSON "${sources.palette}/palette.json").${flavor}.colors;
  in {
    programs.wlogout = {
      enable = true;
      layout = [{
        label = "lock";
        action = "";
        text = "Lock";
      } {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
      } {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
      } {
        label = "logout";
        action = "hyprctl dispatch exit 0";
        text = "Logout";
      } {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
      }];
      style = ''
        window {
          font-family: "${thm.fonts.mono.family}";
          font-size: 18pt;
          color: ${palette.text.hex};
          background-color: rgba(${toString palette.base.rgb.r}, ${toString palette.base.rgb.g}, ${toString palette.base.rgb.b}, 0.8);
        }
        button {
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          border: none;
          background-color: rgba(${toString palette.base.rgb.r}, ${toString palette.base.rgb.g}, ${toString palette.base.rgb.b}, 0);
          color: ${palette.${accent}.hex};
        }
        button:hover {
          background-color: rgba(${toString palette.surface0.rgb.r}, ${toString palette.surface0.rgb.g}, ${toString palette.surface0.rgb.b}, 0.1);
        }
        button:focus {
          background-color: ${palette.${accent}.hex};
          color: ${palette.base.hex};
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
  };
}