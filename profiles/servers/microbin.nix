{ config, pkgs, lib, ... }: {
  secrets.microbin-pass.services = [ "microbin.service" ];

  systemd.services.microbin = {
    description = "MicroBin";
    path = [ pkgs.microbin ];
    script = ''
      mkdir -p /var/microbin
      cd /var/microbin
      MICROBIN_PASS=$(cat /var/secrets/microbin-pass)
      microbin --editable --highlightsyntax --private -b 127.0.0.1 -p 9988 --auth-username ataraxiadev --auth-password $MICROBIN_PASS
    '';
    serviceConfig = {
      Restart = "always";
      Type = "simple";
    };
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };
}
