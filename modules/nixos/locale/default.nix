{ config, lib, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.locale;

  c = "C.UTF-8";
  dk = "en_DK.UTF-8";
  gb = "en_GB.UTF-8";
  ie = "en_IE.UTF-8";
  ru = "ru_RU.UTF-8";
  us = "en_US.UTF-8";
  lang = "en_IE:en_US:en:C:ru_RU";
in
{
  options.ataraxia.defaults.locale = {
    enable = mkEnableOption "Default locale settings";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "us,ru";
      XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    };
    i18n.defaultLocale = ie;
    i18n.extraLocaleSettings = {
      LANGUAGE = lang;
      LC_TIME = dk;
      LC_ADDRESS = ru;
      LC_MONETARY = ru;
      LC_NUMERIC = ru;
      LC_PAPER = ru;
      LC_TELEPHONE = ru;
    };
    i18n.supportedLocales = map (x: "${x}/UTF-8") [
      c
      dk
      gb
      ie
      ru
      us
    ];
    time.timeZone = mkDefault "Europe/Moscow";
  };
}
