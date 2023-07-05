{ config, pkgs, lib, ... }: {
  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [
      (retroarch.override { cores = with libretro; [ genesis-plus-gx dosbox ]; })
      pcsx2 rpcs3
    ];
  };
  persist.state.homeDirectories = [
    ".config/retroarch"
    ".config/PCSX2"
    ".config/rpcs3"
  ];
}