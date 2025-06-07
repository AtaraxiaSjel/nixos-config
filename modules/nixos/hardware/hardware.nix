{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) enum nullOr;

  cfg = config.ataraxia.defaults.hardware;
in
{
  options.ataraxia.defaults.hardware = {
    enable = mkEnableOption "Default hardware settings";
    graphics = mkEnableOption "Enable hardware.graphics module";
    cpuVendor = mkOption {
      default = null;
      type = nullOr (enum [
        "amd"
        "intel"
      ]);
    };
    gpuVendor = mkOption {
      default = null;
      type = nullOr (enum [
        "amd"
        "intel"
        "nvidia"
      ]);
    };
  };

  config = mkIf cfg.enable (
    lib.mkMerge [
      {
        hardware.cpu.${cfg.cpuVendor}.updateMicrocode = true;
        hardware.enableRedistributableFirmware = true;
      }
      (lib.mkIf (cfg.graphics) {
        boot.initrd.kernelModules =
          if (cfg.gpuVendor == "amd") then
            [
              "amdgpu"
            ]
          else if (cfg.gpuVendor == "intel") then
            [
              "i915"
            ]
          else
            [ ];

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages =
            if cfg.gpuVendor == "intel" then
              [
                pkgs.intel-media-driver
                pkgs.intel-vaapi-driver
                pkgs.libvdpau-va-gl
              ]
            else
              [ ];
        };

        hardware.amdgpu = lib.mkIf (cfg.gpuVendor == "amd") {
          opencl.enable = false;
          initrd.enable = config.boot.initrd.systemd.enable;
        };

        environment.sessionVariables =
          if (cfg.gpuVendor == "intel") then
            {
              GST_VAAPI_ALL_DRIVERS = "1";
              LIBVA_DRIVER_NAME = "iHD";
              VDPAU_DRIVER = "va_gl";
            }
          else if (cfg.gpuVendor == "amd") then
            {
              AMD_VULKAN_ICD = "RADV";
            }
          else
            { };
      })
    ]
  );
}
