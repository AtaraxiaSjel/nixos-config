{ config, inputs, ... }: {
  sops.secrets.hoyolab-cookie1.sopsFile = inputs.self.secretsDir + /home-hypervisor/hoyolab.yaml;
  sops.secrets.hoyolab-cookie2.sopsFile = inputs.self.secretsDir + /home-hypervisor/hoyolab.yaml;
  sops.secrets.hoyolab-cookie3.sopsFile = inputs.self.secretsDir + /home-hypervisor/hoyolab.yaml;

  services.hoyolab-daily-bot = {
    enable = true;
    cookieFiles = [
      config.sops.secrets.hoyolab-cookie1.path
      config.sops.secrets.hoyolab-cookie2.path
      config.sops.secrets.hoyolab-cookie3.path
    ];
  };
}
