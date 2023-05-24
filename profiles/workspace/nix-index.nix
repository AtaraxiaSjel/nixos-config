{ config, lib, pkgs, ... }: {
  home-manager.users.${config.mainuser} = {
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = [
      pkgs.nix-index-update
    ];

    # systemd.user.services.nix-index-update = {
    #   Service = {
    #     ExecStart = lib.getExe pkgs.nix-index-update;
    #     Type = "oneshot";
    #   };
    #   Unit.After = [ "network.target" ];
    #   Install.WantedBy = [ "default.target" ];
    # };
  };
  programs.command-not-found.enable = lib.mkForce false;

  # FIXME
  # persist.derivative.homeDirectories = [ ".cache/nix-index" ];
}