inputs: final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
  unstable = import inputs.nixpkgs-unstable {
    config = {
      allowUnfree = true;
    };
    localSystem = { inherit system; };
  };
in
{
  quadpin = inputs.quadpin.packages.${system}.quadpin;

  llama-cpp = final.llama-cpp-vulkan-tuned;
  llama-cpp-rocm = unstable.llama-cpp-rocm;
  llama-cpp-vulkan = unstable.llama-cpp-vulkan;

  llama-cpp-vulkan-tuned = unstable.llama-cpp-vulkan.overrideAttrs (oa: {
    NIX_CFLAGS_COMPILE =
      (oa.NIX_CFLAGS_COMPILE or "") + " -march=znver5 -mtune=znver5 -O3 -flto=auto -ffat-lto-objects";
    NIX_LDFLAGS = (oa.NIX_LDFLAGS or "") + " -flto=auto";
  });
  llama-cpp-rocm-tuned =
    (unstable.llama-cpp.override {
      rocmSupport = true;
      rocmGpuTargets = [ "gfx1031" ];
    }).overrideAttrs
      (oa: {
        NIX_CFLAGS_COMPILE = (oa.NIX_CFLAGS_COMPILE or "") + " -march=znver5 -O3";
      });
}
