# tachyon — phase-6 custom kernel, wired into the system.
#
# - boot.kernelPackages: linuxPackages set over the cross-built trial
#   package (flake output packages.x86_64-linux.tachyon-kernel: aarch64
#   Image+modules built x86_64->aarch64, ~15 min). Consumed as data via the
#   standard linuxPackagesFor pattern. The kernel itself is defined in
#   hosts/tachyon/kernel/package.nix; sources come from the armbian-build
#   flake input, our deviations in hosts/tachyon/kernel/delta-v1.conf.
# - hardware.deviceTree.name: our kernel SHIPS rk3566-nanopi-r3s-lts.dtb
#   (vendored armbian dt, registered in the in-tree Makefile by package.nix),
#   so the board's r3s fallback is flipped to the LTS tree. kernelPackage
#   defaults to boot.kernelPackages.kernel, so the dtb resolves from OUR
#   kernel automatically. mkForce: the board module assigns the fallback at
#   default priority.
# - boot.initrd.availableKernelModules: board list minus the 6 display/HDMI
#   modules (analogix_dp rockchipdrm dw_hdmi dw_hdmi_cec dw_hdmi_i2s_audio
#   dw_mipi_dsi) — DRM=n headless, they don't exist in our kernel, and the
#   initrd builder fails hard on missing modules (modules-closure.sh,
#   allowMissing=false). Verified per-module with modprobe --show-depends
#   against the built kernel: everything else resolves (builtin or .ko,
#   including old-spelling aliases sdhci_of_dwcmshc/naneng_combphy and =m
#   rockchip-rga/r8169/realtek/snps-pcie3). mkForce carries the full list:
#   keep in sync with the board's modules/common.nix if it ever changes.
{
  flake-self,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelPackages = pkgs.linuxPackagesFor flake-self.packages.x86_64-linux.tachyon-kernel;

  hardware.deviceTree.name = lib.mkForce "rockchip/rk3566-nanopi-r3s-lts.dtb";

  boot.initrd.availableKernelModules = lib.mkForce [
    # SD/MMC root (dwmmc_rockchip on fe2b0000.mmc)
    "sdhci_of_dwcmshc"
    "dw_mmc_rockchip"
    # Native GMAC (rk_gmac-dwmac: dwmac_rk + stmmac stack)
    "dwmac_rk"
    "stmmac_platform"
    "stmmac"
    "pcs_xpcs"
    # PCIe Realtek NIC (r8169 + realtek PHY)
    "pcie_rockchip_host"
    "phy-rockchip-pcie"
    "phy_rockchip_snps_pcie3"
    "phy_rockchip_naneng_combphy"
    "r8169"
    "realtek"
    # USB / power / thermal / watchdog
    "phy_rockchip_inno_usb2"
    "io-domain"
    "rockchip_saradc"
    "rockchip_thermal"
    "dw_wdt"
    # Display/HDMI deliberately absent (DRM=n, see header). rockchip-rga
    # stays: V4L2 media driver, still =m in our kernel.
    "rockchip-rga"
  ];
}
