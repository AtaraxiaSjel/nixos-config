{ config, lib, pkgs, ... }: {
  home-manager.users.alukard = {
    home.packages = [ pkgs.google-drive-ocamlfuse ];
    # systemd.user.services.google-drive-ocamlfuse = {
    #   Service = {
    #     ExecStart = "${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse";
    #     Type = "simple";
    #   };
    #   Unit = rec {
    #     After = [ "network-online.target" ];
    #     Wants = After;
    #   };
    #   Install.WantedBy = [ "multi-user.target" ];
    # };
  };
}