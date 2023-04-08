{ config, pkgs, lib, ... }: {
  sound.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # TODO: create drop-in files in /etc/pipewire/pipewire.conf.d/
    # config.pipewire-pulse = {
    #   "context.modules" = [
    #     {
    #       "name" = "libpipewire-module-rtkit";
    #       "args" = {};
    #       "flags" = [
    #         "ifexists"
    #         "nofail"
    #       ];
    #     }
    #     {
    #       "name" = "libpipewire-module-protocol-native";
    #     }
    #     {
    #       "name" = "libpipewire-module-client-node";
    #     }
    #     {
    #       "name" = "libpipewire-module-adapter";
    #     }
    #     {
    #       "name" = "libpipewire-module-metadata";
    #     }
    #     {
    #       "name" = "libpipewire-module-protocol-pulse";
    #       "args" = {
    #         "server.address" = [
    #             "unix:native"
    #             "tcp:127.0.0.1:8888" # IPv4 on a single address
    #         ];
    #         "vm.overrides" = {
    #           "pulse.min.quantum" = "1024/48000";
    #         };
    #       };
    #     }
    #   ];
    # };
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
    xdg.configFile."wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.hw-volume"] = "[ hfp_ag hsp_ag a2dp_source a2dp_sink ]",
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag a2dp_sink ]",
        ["bluez5.reconnect-profiles"] = "[ hsp_hs hfp_hf a2dp_sink ]",
      }
    '';
    home.packages = [ pkgs.pavucontrol pkgs.pulseaudio ];
  };

  security.rtkit.enable = true;

  hardware.pulseaudio.enable = lib.mkForce false;
  services.jack.jackd.enable = lib.mkForce false;
}