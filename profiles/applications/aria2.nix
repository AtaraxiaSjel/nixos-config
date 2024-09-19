{ config, pkgs, ... }: {
  # TODO: enable websocket (--rpc-certificate)
  home-manager.users.${config.mainuser} = { config, ...}:
  let
    homeDir = config.home.homeDirectory;
  in {
    # home.packages = [ pkgs.ariang ];
    programs.aria2 = {
      enable = true;
      settings = {
        ### Basic ###
        dir = "${homeDir}/Downloads";
        input-file = "${homeDir}/.config/aria2/aria2.session";
        save-session = "${homeDir}/.config/aria2/aria2.session";
        save-session-interval = 60;
        max-concurrent-downloads = 5;
        continue = true;
        max-overall-download-limit = 0;
        max-download-limit = 0;
        quiet = true;

        ### Advanced ###
        allow-overwrite = true;
        allow-piece-length-change = true;
        always-resume = true;
        async-dns = false;
        auto-file-renaming = true;
        content-disposition-default-utf8 = true;
        disk-cache = "64M";
        file-allocation = "falloc";
        no-file-allocation-limit = "8M";
        # Set log level to output to console. LEVEL is either debug, info, notice, warn or error. Default: notice
        console-log-level = "notice";
        # Set log level to output. LEVEL is either debug, info, notice, warn or error. Default: debug
        log-level = "warn";
        log = "${homeDir}/.config/aria2/aria2.log";

        ### RPC ###
        enable-rpc = true;
        pause = false;
        rpc-save-upload-metadata = true;
        rpc-allow-origin-all = true;
        rpc-listen-all = false;
        rpc-listen-port = 49100;
        # rpc-secret=
        # The certificate must be either in PKCS12 (.p12, .pfx) or in PEM format. When using PEM, you have to specify the private key via --rpc-private-key as well.
        # rpc-certificate=
        # rpc-private-key=
        rpc-secure = false;

        ### HTTP/FTP/SFTP ###
        max-connection-per-server = 16;
        min-split-size = "8M";
        split = 32;
        # user-agent = "Transmission/4.0.2";

        ### BitTorrent ###
        # bt-save-metadata=false
        listen-port = "49101-49109";
        # max-overall-upload-limit=256K
        # max-upload-limit=0
        seed-ratio = 0.1;
        seed-time = 0;
        # bt-enable-lpd = false;
        enable-dht = true;
        enable-dht6 = true;
        dht-listen-port = "49101-49109";
        dht-entry-point = "dht.transmissionbt.com:6881";
        dht-entry-point6 = "dht.transmissionbt.com:6881";
        dht-file-path = "${homeDir}/.config/aria2/dht.dat";
        dht-file-path6 = "${homeDir}/.config/aria2/dht6.dat";
        enable-peer-exchange = true;
        # peer-id-prefix = "-TR2770-";
        peer-agent = "Transmission/4.0.2";
        # bt-tracker = "";
      };
    };

    systemd.user.services.aria2 = {
      Unit.Description = "aria2 is a download utility operated in command-line";
      Service = {
        Restart = "on-failure";
        ExecStart = "${pkgs.aria2}/bin/aria2c";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };

  systemd.tmpfiles.rules = [
    "f /home/${config.mainuser}/.config/aria2/aria2.session 0644 ${config.mainuser} users -"
    "f /home/${config.mainuser}/.config/aria2/dht.dat 0644 ${config.mainuser} users -"
    "f /home/${config.mainuser}/.config/aria2/dht6.dat 0644 ${config.mainuser} users -"
  ];

  persist.state.homeDirectories = [ ".config/aria2" ];
}