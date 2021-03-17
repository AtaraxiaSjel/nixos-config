{ config, pkgs, lib, ... }: {
  hardware.pulseaudio = {
    enable = true;
    # package = pkgs.pulseaudioFull;
    support32Bit = true;
    systemWide = true;
    tcp = {
      enable = true;
      anonymousClients.allowedIpRanges = ["127.0.0.1"];
    };
    daemon.config = {
      high-priority = "yes";
      nice-level = "-15";

      realtime-scheduling = "yes";
      realtime-priority = "9";

      resample-method = "speex-float-8";
      avoid-resampling = "yes";

      enable-lfe-remixing = "no";
      flat-volumes = "no";

      rlimit-rtprio = "9";

      default-sample-format = "float32le";
      default-sample-rate = "48000";
      alternate-sample-rate = "96000";
      default-sample-channels = "2";
      default-channel-map = "front-left,front-right";

      default-fragments = "2";
      default-fragment-size-msec = "10";

      deferred-volume-safety-margin-usec = "1";

      # FIXIT
      enable-memfd = "no";
    };
  };
}