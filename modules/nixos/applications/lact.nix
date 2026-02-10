{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.programs.lact;
in
{
  options.ataraxia.programs.lact = {
    enable = mkEnableOption "Enable lact program";
  };

  config = mkIf cfg.enable {
    services.lact.enable = true;
    # services.lact.settings = {};

    hardware.amdgpu.overdrive.enable = true;
    # hardware.amdgpu.overdrive.ppfeaturemask = "0xffffffff";
  };
}
