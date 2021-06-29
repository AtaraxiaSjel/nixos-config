{ pkgs, ... }: {
  services.mopidy = {
    enable = true;
    # dataDir = "";
    configuration = ''
      [audio]
      output = pulsesink server=127.0.0.1:8888

      [mpd]
      enabled = true
      hostname = 127.0.0.1
      port = 6600

      [local]
      media_dir = /home/alukard/Music
    '';
    extensionPackages = with pkgs; [
      mopidy-local
      # mopidy-mpris
      mopidy-mpd
    ];
  };

  # systemd.services.mopidy-scan = {
  #   description = "mopidy local files cleaner";
  #   serviceConfig = {
  #     ExecStart = "${mopidyEnv}/bin/mopidy local clear";
  #     User = "mopidy";
  #     Type = "oneshot";
  #   };
  # };
}