{ pkgs, lib, ... }: {
  sound.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            "bluez5.hw-volume" = [ "hfp_ag" "hsp_ag" "a2dp_source" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
    # media-session.config.bluez-monitor = {
    #   properties = { };
    #   rules = [
    #     {
    #       actions = {
    #         update-props = {
    #           "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
    #           "bluez5.hw-volume" =
    #             [ "hfp_ag" "hsp_ag" "a2dp_source" "a2dp_sink" ];
    #         };
    #       };
    #       matches = [{ "device.name" = "~bluez_card.*"; }];
    #     }
    #     {
    #       actions = { update-props = { "node.pause-on-idle" = false; }; };
    #       matches = [
    #         { "node.name" = "~bluez_input.*"; }
    #         { "node.name" = "~bluez_output.*"; }
    #       ];
    #     }
    #   ];
    # };
  };

  security.rtkit.enable = true;

  home-manager.users.alukard.home.packages = [ pkgs.pavucontrol pkgs.pulseaudio ];

  hardware.pulseaudio.enable = lib.mkForce false;
  services.jack.jackd.enable = lib.mkForce false;
}