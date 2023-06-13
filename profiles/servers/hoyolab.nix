{ config, pkgs, lib, ... }: {
  secrets.hoyolab-cookie1.services = [ ];
  secrets.hoyolab-cookie2.services = [ ];
  secrets.hoyolab-cookie3.services = [ ];
  
  services.hoyolab-daily-bot = {
    enable = true;
    cookieFiles = [
      config.secrets.hoyolab-cookie1.decrypted
      config.secrets.hoyolab-cookie2.decrypted
      config.secrets.hoyolab-cookie3.decrypted
    ];
  };
}
