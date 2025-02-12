{ config, pkgs, lib, ... }: {
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.jack.jackd.enable = lib.mkForce false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig = {
      "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
    extraConfig.client = {
      "10-no-resample" = {
        "stream.properties" = {
          "resample.disable" = true;
        };
      };
    };
  };

  home-manager.users.${config.mainuser} = {
    home.packages = [ pkgs.pavucontrol pkgs.pulseaudio ];
    services.easyeffects.enable = true;
    xdg.configFile = {
      "easyeffects/output/HE4XX.json".text =
        builtins.readFile ./easyeffects/HE4XX.json;
      "easyeffects/output/Bluetooth.json".text =
        builtins.readFile ./easyeffects/Bluetooth.json;
      "easyeffects/input/noise_redaction.json".text =
        builtins.readFile ./easyeffects/noise_reduction.json;
    };
  };

  persist.state.homeDirectories = [ ".local/state/wireplumber" ];
}