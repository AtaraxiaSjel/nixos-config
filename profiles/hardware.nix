{ config, lib, pkgs, ... }:
with config.deviceSpecific; {
  config = lib.mkMerge [
    ({
      hardware.cpu.${devInfo.cpu.vendor}.updateMicrocode = true;
      hardware.enableRedistributableFirmware = true;

      boot.initrd.kernelModules = if devInfo.gpu.vendor == "amd" then [
        "amdgpu"
      ] else if devInfo.gpu.vendor == "intel" then [
        "i915"
      ] else [ ];
    })
    (lib.mkIf (!isServer) {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = if devInfo.gpu.vendor == "intel" then [
          pkgs.intel-media-driver
          pkgs.intel-vaapi-driver
          pkgs.libvdpau-va-gl
        ] else if devInfo.gpu.vendor == "amd" then [
          pkgs.rocmPackages.clr.icd
        ] else [ ];
      };

      environment.sessionVariables = if (devInfo.gpu.vendor == "intel") then {
        GST_VAAPI_ALL_DRIVERS = "1";
        LIBVA_DRIVER_NAME = "iHD";
        VDPAU_DRIVER = "va_gl";
      } else if (devInfo.gpu.vendor == "amd") then {
        AMD_VULKAN_ICD = "RADV";
      } else {};
    })
  ];
}
