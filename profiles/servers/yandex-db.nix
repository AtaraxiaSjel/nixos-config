{ config, lib, pkgs, ... }: {
  secrets.yandex-token = {};

  systemd.services.yandex-db = {
    description = "Gathers data on rides taken via Yandex Taxi.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.yandex-taxi-py;
    };
    startAt = "*:0/15";
  };
}