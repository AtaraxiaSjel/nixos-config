{ pkgs, config, lib, ... }:
with config.deviceSpecific; {

  hardware.cpu.${devInfo.cpu.vendor}.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # Enable hardware video acceleration for Intel
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl =  {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = if devInfo.gpu.vendor == "intel" then [
      pkgs.intel-media-driver
    ] else if devInfo.gpu.vendor == "intel" then [
      pkgs.amdvlk
    ] else [ ];
    extraPackages32 = lib.mkIf (devInfo.gpu.vendor == "amd") [
      pkgs.driversi686Linux.amdvlk
    ];
  };
  environment.sessionVariables = {
    GST_VAAPI_ALL_DRIVERS = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };
  boot.initrd.kernelModules = lib.mkIf (devInfo.gpu.vendor == "amd") [ "amdgpu" ];
  # environment.systemPackages = if devInfo.gpu.vendor == "amd" then
  #   # [ (pkgs.mesa.override { enableRadv = true; }) ]
  #   [ pkgs.mesa ]
  # else
  #   [ ];
}
