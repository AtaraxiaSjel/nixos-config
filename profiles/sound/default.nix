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
    # Change this:
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
    # To this, once https://github.com/NixOS/nixpkgs/pull/292115 is merged
    # wireplumber.extraLuaConfig.bluetooth."51-bluez-config" = ''
    #   bluez_monitor.properties = {
    #     ["bluez5.enable-sbc-xq"] = true,
    #     ["bluez5.enable-msbc"] = true,
    #     ["bluez5.enable-hw-volume"] = true,
    #     ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
    #   }
    # '';
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