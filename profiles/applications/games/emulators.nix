{ config, pkgs, lib, ... }: {
  boot.kernel.sysctl."vm.max_map_count" = lib.mkForce 524288;
  home-manager.users.${config.mainuser} = {
    home.packages = with pkgs; [
      (retroarch.override { cores = with libretro; [ genesis-plus-gx dosbox ]; })
      ryujinx
      # citra-canary
      # pcsx2
      # rpcs3
    ];
  };
  persist.state.homeDirectories = [
    ".config/citra-emu"
    ".config/PCSX2"
    ".config/retroarch"
    ".config/rpcs3"
    ".config/Ryujinx"
  ];
}