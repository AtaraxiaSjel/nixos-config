{ config, lib, ... }:
let
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.ataraxia.defaults.locale;

  dk = "en_DK.UTF-8";
  gb = "en_GB.UTF-8";
  ie = "en_IE.UTF-8";
  ru = "ru_RU.UTF-8";
  us = "en_US.UTF-8";
  lang = "en_US:en:C:ru_RU:ru";
in
{
  options.ataraxia.defaults.locale = {
    enable = mkEnableOption "Default locale settings";
  };

  config = mkIf cfg.enable {
    # Locale
    i18n.defaultCharset = "UTF-8";
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
    i18n.extraLocales = map (x: "${x}/${config.i18n.defaultCharset}") [
      gb
      us
    ];
    # Keyboard layout
    console.earlySetup = true;
    console.useXkbConfig = true;
    services.xserver.xkb = {
      layout = "us,ru";
      options = "grp:win_space_toggle";
    };
    # Timezone
    time.timeZone = mkDefault "Europe/Moscow";
  };
}
