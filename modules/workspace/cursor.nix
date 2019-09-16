{ config, lib, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    bibata-cursors
  ];
  # Bibata_Amber, Bibata_Ice, Bibata_Oil
  home-manager.users.alukard.home.file.".icons/default" = {
    source = "${pkgs.bibata-cursors}/share/icons/Bibata_Oil";
  };
}
