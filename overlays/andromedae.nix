inputs: final: prev:
let
  inherit (prev.stdenv.hostPlatform) system;
  inherit (final) lib;
  unstable = import inputs.nixpkgs-unstable {
    config = {
      allowUnfree = true;
    };
    localSystem = { inherit system; };
  };

  eden-zenver5 = unstable.eden.overrideAttrs (old: {
    NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -march=znver5 -mtune=znver5";
  });
  d3Stick = prev.writers.writePython3 "d3Stick" {
    libraries = [ prev.python3Packages.evdev ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./d3stick.py);
  eden-launcher = prev.writeShellScript "eden-launcher" ''
    ${d3Stick} &
    STICK_PID=$!
    cleanup() {
      kill "$STICK_PID" 2>/dev/null
    }
    trap cleanup EXIT INT TERM
    ${eden-zenver5}/bin/eden "$@"
  '';
  eden-with-d3 = prev.symlinkJoin {
    inherit (eden-zenver5) meta version;
    name = "${lib.getName eden-zenver5}-wrapped-${lib.getVersion eden-zenver5}";
    paths = [ eden-zenver5 ];
    preferLocalBuild = true;
    buildInputs = [ prev.makeWrapper ];
    postBuild = ''
      rm -f $out/bin/eden
      ln -sf ${eden-launcher} $out/bin/eden
    '';
  };
in
{
  quadpin = inputs.quadpin.packages.${system}.quadpin;

  eden = eden-with-d3;

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
