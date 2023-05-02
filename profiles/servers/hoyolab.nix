{ config, pkgs, lib, ... }: {
  secrets.hoyolab-cookie1 = { };
  secrets.hoyolab-cookie2 = { };
  services.hoyolab-daily-bot = {
    enable = true;
    cookieFiles = [
      config.secrets.hoyolab-cookie1.decrypted
      config.secrets.hoyolab-cookie2.decrypted
    ];
  };
}