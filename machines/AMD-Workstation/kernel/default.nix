{ config, pkgs, lib, ... }: {
  # boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor pkgs.linuxLqxZfs);
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_lqx_clang;

  nixpkgs.overlays = let
    inherit (pkgs) overrideCC ccacheWrapper addAttrsToDerivation pkgsBuildHost pkgsBuildBuild;

    llvmPackages = "llvmPackages_18";
    noBintools = { bootBintools = null; bootBintoolsNoLibc = null; };
    mkLLVMPlatform = platform: platform // { useLLVM = true; };

    # Get llvmPackages for host and build platforms, disabling bootBintools
    hostLLVM = pkgsBuildHost.${llvmPackages}.override noBintools;
    # buildLLVM = pkgsBuildBuild.${llvmPackages}.override noBintools; # unused

    # Get LLVM stdenv with clang
    stdenvClangUseLLVM = overrideCC hostLLVM.stdenv hostLLVM.clangUseLLVM;

    # set useLLVM to true for host and build platforms
    stdenvPlatformLLVM = stdenvClangUseLLVM.override (old: {
      hostPlatform = mkLLVMPlatform old.hostPlatform;
      buildPlatform = mkLLVMPlatform old.buildPlatform;
    });

    # Wrap clang with ccache
    stdenvCcacheLLVM = overrideCC stdenvPlatformLLVM (
      ccacheWrapper.override { cc = stdenvPlatformLLVM.cc; }
    );

    # Disable fortify hardening as LLVM does not support it, and disable response file
    stdenvLLVM = addAttrsToDerivation {
      env.NIX_CC_USE_RESPONSE_FILE = "0";
      hardeningDisable = [ "fortify" ];
    } stdenvCcacheLLVM;
  in [
    (final: prev: {
      # debug
      inherit stdenvLLVM stdenvCcacheLLVM stdenvPlatformLLVM;

      linuxPackages_lqx_clang = prev.linuxPackages_lqx.extend (lpfinal: lpprev: {
        kernel = (lpprev.kernel.override {
          buildPackages = final.buildPackages // { stdenv = stdenvLLVM; };
          stdenv = stdenvLLVM;
          argsOverride = let
            version = "6.10.3";
            suffix = "lqx1";
            hash = "sha256-495xe6wZOMwy/N9yqwlGLTcAWuubUzmfoGOV7J1RWGk=";

            no-dynamic-linker-patch = {
              name = "no-dynamic-linker";
              patch = ./no-dynamic-linker.patch;
            };
            fix-znver-clang18 = {
              name = "fix-znver-clang18";
              patch = ./fix-znver-clang18.patch;
            };
          in {
            inherit version;
            modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
            src = prev.fetchFromGitHub {
              owner = "zen-kernel";
              repo = "zen-kernel";
              rev = "v${version}-${suffix}";
              inherit hash;
            };
            extraMakeFlags = [ "LLVM=1" "LLVM_IAS=1" ];
            kernelPatches = [ no-dynamic-linker-patch fix-znver-clang18 ] ++ lpprev.kernel.kernelPatches;
            structuredExtraConfig = with lib.kernel;
              lpprev.kernel.structuredExtraConfig //
                builtins.mapAttrs (_: v: lib.mkForce v) {
                  CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;
                  # GENERIC_CPU3 = yes;
                  MZEN = yes;
                  INIT_ON_ALLOC_DEFAULT_ON = yes;
                  INIT_STACK_ALL_ZERO = yes;
                  LTO_CLANG_FULL = yes;
                  MODULE_COMPRESS_XZ = no;
                  MODULE_COMPRESS_ZSTD = yes;
                  RCU_BOOST = no;
                  RCU_BOOST_DELAY = option (freeform "500");
                  RCU_LAZY = no;
                };
          };
        });
      });
    })
  ];

  assertions = [{
    assertion = config.programs.ccache.enable;
    message = "To compile custom kernel you must enable and setup ccache";
  }];
}
