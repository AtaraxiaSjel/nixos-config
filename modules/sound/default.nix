{ config, lib, pkgs, ... }: {
  sound.enable = true;

  hardware.pulseaudio = {
    enable = true;
    # package = pkgs.pulseaudioFull;
    support32Bit = true;
    # systemWide = true;
    tcp = {
      enable = true;
      anonymousClients.allowedIpRanges = ["127.0.0.1"];
    };

    extraConfig = ''
      avoid-resampling = yes

      high-priority = yes
      nice-level = -17

      realtime-scheduling = yes
      realtime-priority = 9

      resample-method = speex-float-8
      avoid-resampling = yes
      enable-lfe-remixing = no

      flat-volumes = no
      rlimit-rtprio = 9

      default-sample-format = float32le
      default-sample-rate = 44100
      alternate-sample-rate = 96000
      default-sample-channels = 2
      default-channel-map = front-left,front-right

      default-fragments = 2
      default-fragment-size-msec = 125

      deferred-volume-safety-margin-usec = 1
    '';
  };
}