# tachyon custom kernel (phase 6): cross x86_64 -> aarch64.
# Sources come from the armbian-build flake input (pinned commit), NOT
# vendored: the rockchip64-6.18 patch stack + dt/overlay + base config are
# read straight from the input at eval time. That is pure (inputs are
# fetched before eval), so no import-from-derivation is involved.
# Our deviations live in delta-v1.conf (a few reviewed lines). The merged
# config is materialized with writeText (a normal build-time dep, not IFD)
# and parsed with the same =y/=m regex nixpkgs uses (kernel/build.nix
# readConfig), so passthru.config stays honest: explicit `config` bypasses
# the isPath/IFD gate that would otherwise silently set isModular=false.
# Trial package only, NOT wired into any system yet.
{
  lib,
  pkgsCross,
  applyPatches,
  runCommand,
  writeText,
  linux_6_18,
  armbianSrc,
}:
let
  kcross = pkgsCross.aarch64-multiplatform;
  # NOTE: src/version taken from the native set (kernel tarball is
  # arch-independent); only the build itself runs under the cross stdenv.
  # (top-level linux_6_18 IS the kernel derivation; the set is linuxPackages_6_18.)
  baseKernel = linux_6_18;

  rockchipDir = "${armbianSrc}/patch/kernel/archive/rockchip64-6.18";
  patchFiles = lib.sort (a: b: a < b) (
    lib.attrNames (
      lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".patch" n) (builtins.readDir rockchipDir)
    )
  );
  armbianPatches = map (f: rockchipDir + "/${f}") patchFiles;

  patched = applyPatches {
    src = baseKernel.src;
    patches = armbianPatches;
    name = "linux-${baseKernel.version}-armbian-rockchip64-patched";
  };

  dtDir = "${rockchipDir}/dt";
  overlayDir = "${rockchipDir}/overlay";

  finalSrc = runCommand "linux-${baseKernel.version}-armbian-rockchip64" { } ''
    cp -r ${patched} $out
    chmod -R u+w $out
    cp ${dtDir}/*.dts* "$out/arch/arm64/boot/dts/rockchip/"
    mkdir -p "$out/arch/arm64/boot/dts/rockchip/overlay"
    cp ${overlayDir}/*.dtso "$out/arch/arm64/boot/dts/rockchip/overlay/" || true
    # Replicate armbian auto-patch-dt-makefile: register vendored dts files
    # missing from the in-tree Makefile (e.g. rk3566-nanopi-r3s-lts).
    mk="$out/arch/arm64/boot/dts/rockchip/Makefile"
    for dts in ${dtDir}/*.dts; do
      base="''${dts##*/}"; base="''${base%.dts}"
      grep -q "$base.dtb" "$mk" || echo "dtb-\$(CONFIG_ARCH_ROCKCHIP) += $base.dtb" >> "$mk"
    done
  '';

  # Merge order: stock fragment first, delta last (kconfig: last wins).
  # Stock ends with a newline, so plain concatenation matches `cat` bytes.
  mergedText =
    builtins.readFile "${armbianSrc}/config/kernel/linux-rockchip64-current.config"
    + builtins.readFile ./delta-v1.conf;

  # Same parser nixpkgs uses for configfile (kernel/build.nix readConfig):
  # only =y/=m lines; `# ... is not set` correctly stays absent (= disabled).
  parseConfig =
    text:
    let
      matchLine =
        line:
        let
          match = builtins.match "(CONFIG_[^=]+)=([ym])" line;
        in
        lib.optional (match != null) {
          name = lib.elemAt match 0;
          value = lib.elemAt match 1;
        };
    in
    builtins.listToAttrs (lib.concatMap matchLine (lib.splitString "\n" text));
in
# NOTE: linuxPackages_custom (customPackage) has a fixed signature and
# cannot forward `config`; call manualConfig directly so the explicit
# parse above reaches the builder.
kcross.linuxKernel.packagesFor (
  kcross.linuxKernel.manualConfig {
    version = baseKernel.version;
    src = finalSrc;
    configfile = writeText "tachyon-kernel-config-v1" mergedText;
    config = parseConfig mergedText;
  }
)
