{ config, lib, ... }: {
  programs.ccache = {
    enable = true;
    cacheDir = "/var/lib/ccache";
    # packageNames = [ "grub2" ];
  };
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  persist.state.directories = lib.mkIf (config.deviceSpecific.devInfo.fileSystem != "zfs") [
    config.programs.ccache.cacheDir
  ];

  nixpkgs.overlays = [
    (final: prev: {
      ccacheWrapper = prev.ccacheWrapper.override {
        # export CCACHE_SLOPPINESS=random_seed,pch_defines,time_macros,include_file_mtime,include_file_ctime
        extraConfig = ''
          export CCACHE_NOCOMPRESS=true
          export CCACHE_MAXSIZE=15G
          export CCACHE_DIR="${config.programs.ccache.cacheDir}"
          export CCACHE_UMASK=007
          export CCACHE_SLOPPINESS=random_seed
          export CCACHE_BASEDIR=$NIX_BUILD_TOP
        '';
      };
    })
  ];
}
