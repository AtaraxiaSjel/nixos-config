{ pkgs, config, lib, ... }: {

  i18n.defaultLocale = "en_GB.UTF-8";

  console.font = "cyr-sun16";
  console.keyMap = "ruwin_cplk-UTF-8";

  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    LANG = lib.mkForce "en_GB.UTF-8";
  };

  time.timeZone = lib.mkIf (!config.deviceSpecific.isCloud) "Europe/Moscow";

  location = lib.mkIf (!config.deviceSpecific.isCloud) {
    provider = "manual";
    latitude = 48.78583;
    longitude = 44.77973;
  };

  home-manager.users.alukard = {
    home.language = let
      en = "en_GB.UTF-8";
      ru = "ru_RU.UTF-8";
    in {
      address = ru;
      monetary = ru;
      paper = ru;
      time = en;
      base = en;
    };
  };
}
