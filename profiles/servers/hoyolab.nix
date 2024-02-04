{ config, inputs, ... }: {
  imports = [ inputs.ataraxiasjel-nur.nixosModules.hoyolab ];
  sops.secrets.hoyolab-config.sopsFile = inputs.self.secretsDir + /home-hypervisor/hoyolab.yaml;

  services.hoyolab-claim-bot = {
    enable = true;
    configFile = config.sops.secrets.hoyolab-config.path;
    startAt = "*-*-* 20:00:00";
  };
}
