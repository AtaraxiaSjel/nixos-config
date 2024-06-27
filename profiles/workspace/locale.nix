{ config, ... }:
let
  c = "C.UTF-8";
  dk = "en_DK.UTF-8";
  gb = "en_GB.UTF-8";
  ie = "en_IE.UTF-8";
  ru = "ru_RU.UTF-8";
  us = "en_US.UTF-8";
  lang = "en_IE:en_US:en:C:ru_RU";
in {
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
    c dk gb ie ru us
  ];

  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    # LANGUAGE = lang;
    # LC_ALL = en;
  };

  time.timeZone = "Europe/Moscow";

  location = {
    provider = "manual";
    latitude = 48.79;
    longitude = 44.78;
  };

  home-manager.users.${config.mainuser} = {
    home.language = {
      base = ie;
      time = dk;
      address = ru;
      monetary = ru;
      numeric = ru;
      paper = ru;
      telephone = ru;
    };
    home.sessionVariables = {
      LANGUAGE = lang;
    };
  };
}
