{ pkgs, config, lib, ... }:
with config.deviceSpecific; {
  i18n.defaultLocale = "en_GB.utf8";

  console.font = "cyr-sun16";
  # console.keyMap = "ruwin_cplk-UTF-8";

  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us,ru";
    XKB_DEFAULT_OPTIONS = "grp:win_space_toggle";
    LANG = lib.mkForce "en_GB.utf8";
  };

  time.timeZone = "Europe/Moscow";

  location = lib.mkIf (!isServer) {
    provider = "manual";
    latitude = 48.79;
    longitude = 44.78;
  };

  home-manager.users.alukard = {
    home.language = let
      en = "en_GB.utf8";
      ru = "ru_RU.utf8";
    in {
      address = ru;
      monetary = ru;
      paper = ru;
      time = en;
      base = en;
    };
  };
}
