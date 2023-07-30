{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/media/nas/media-stack";
in {
  secrets.mailserver-kavita = { };

  virtualisation.oci-containers.containers = {
    kavita = {
      autoStart = true;
      image = "docker.io/kizaing/kavita:0.7.5";
      environment = {
        PUID = "1000";
        PGID = "100";
      };
      extraOptions = [ "--pod=media-stack" ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${nas-path}/configs/kavita:/kavita/config"
        "${nas-path}/media/manga:/manga/manga"
        "${nas-path}/media/books:/manga/books"
        "${nas-path}/media/comics:/manga/comics"
      ];
    };
    kavitaemail = {
      autoStart = true;
      image = "docker.io/kizaing/kavitaemail:0.1.20";
      environment = {
        SMTP_HOST = "https://mail.ataraxiadev.com";
        SMTP_PORT = "587";
        SMTP_USER = "kavita@ataraxiadev.com";
        SEND_ADDR = "kavita@ataraxiadev.com";
        DISP_NAME = "Kavita <no-reply>";
        ALLOW_SENDTO = "false";
      };
      environmentFiles = [ config.secrets.mailserver-kavita.decrypted ];
      extraOptions = [ "--pod=media-stack" ];
    };
  };
}