{ config, pkgs, inputs, ... }: {
  sops.secrets.yandex-token.sopsFile = inputs.self.secretsDir + /home-hypervisor/yandex.yaml;

  systemd.services.yandex-db = {
    description = "Gathers data on rides taken via Yandex Taxi.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.yandex-taxi-py} ${config.sops.secrets.yandex-token.path}";
    };
    startAt = "*:0/15";
  };
}