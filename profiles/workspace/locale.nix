{ config, ... }:
let
  en = "en_US.UTF-8";
  ru = "ru_RU.UTF-8";
in {
  i18n.defaultLocale = en;
  i18n.extraLocaleSettings = {
    LANGUAGE = en;
    LC_ALL = en;
    LC_TIME = en;
    LC_ADDRESS = ru;
    LC_MONETARY = ru;
    LC_PAPER = ru;
  };
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "en_GB.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    LANGUAGE = en;
    LC_ALL = en;
  };

  time.timeZone = "Europe/Moscow";

  location = {
    provider = "manual";
    latitude = 48.79;
    longitude = 44.78;
  };

  home-manager.users.${config.mainuser} = {
    home.language = {
      address = ru;
      monetary = ru;
      paper = ru;
      time = en;
      base = en;
    };
  };
}
