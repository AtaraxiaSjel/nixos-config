{ config, pkgs, lib, ... }: {
  sound.enable = false;
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
  services.jack.jackd.enable = lib.mkForce false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.hw-volume"] = "[ hfp_ag hsp_ag a2dp_source a2dp_sink ]",
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag a2dp_sink ]",
        ["bluez5.reconnect-profiles"] = "[ hsp_hs hfp_hf a2dp_sink ]",
      }
    '';
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
}