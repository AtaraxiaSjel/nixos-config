{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.locale;

  dk = "en_DK.UTF-8";
  ie = "en_IE.UTF-8";
  ru = "ru_RU.UTF-8";
in
{
  options.ataraxia.defaults.locale = {
    enable = mkEnableOption "Default locale settings";
  };

  config = mkIf cfg.enable {
    home.language = {
      base = ie;
      address = ru;
      monetary = ru;
      numeric = ru;
      paper = ru;
      telephone = ru;
      time = dk;
    };
  };
}
