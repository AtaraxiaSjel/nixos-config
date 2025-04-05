{ config, lib, pkgs, ... }: {
  # systemd.services = let
  #   service = user: group: {
  #     wantedBy = [ "multi-user.target" ];
  #     wants = [ "network-online.target" ];
  #     after = [ "network-online.target" ];
  #     path = [ pkgs.nix-index-update ];
  #     serviceConfig = {
  #       Type = "oneshot";
  #       ExecStart = lib.getExe pkgs.nix-index-update;
  #       User = user;
  #       Group = group;
  #     };
  #   };
  # in {
  #   "nix-index-update-root" = service "root" "root";
  #   "nix-index-update-${config.mainuser}" = service config.mainuser "users";
  # };
  home-manager.users.${config.mainuser} = {
    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    home.packages = [
      pkgs.nix-index-update
    ];
  };
  programs.command-not-found.enable = lib.mkForce false;
}