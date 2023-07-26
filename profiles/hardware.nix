{ pkgs, config, lib, ... }:
with config.deviceSpecific; {

  hardware.cpu.${devInfo.cpu.vendor}.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl =  {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = if devInfo.gpu.vendor == "intel" then [
      pkgs.intel-media-driver
    ] else if devInfo.gpu.vendor == "amd" then [
      # pkgs.amdvlk
      pkgs.rocm-opencl-icd
      pkgs.rocm-opencl-runtime
    ] else [ ];
    extraPackages32 = lib.mkIf (devInfo.gpu.vendor == "amd") [
      # pkgs.driversi686Linux.amdvlk
    ];
  };
  environment.sessionVariables = if (devInfo.gpu.vendor == "intel") then {
    GST_VAAPI_ALL_DRIVERS = "1";
    LIBVA_DRIVER_NAME = "iHD";
  } else if (devInfo.gpu.vendor == "amd") then {
    AMD_VULKAN_ICD = "RADV";
  } else {};
  boot.initrd.kernelModules = if devInfo.gpu.vendor == "amd" then [
    "amdgpu"
  ] else if devInfo.gpu.vendor == "intel" then [
    "i915"
  ] else [ ];
}
