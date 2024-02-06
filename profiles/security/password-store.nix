{ config, inputs, ... }: {
  sops.secrets.git-ssh-key = {
    owner = config.mainuser;
    sopsFile = inputs.self.secretsDir + /misc.yaml;
  };
  services.password-store = {
    enable = true;
    repo = "gitea@code.ataraxiadev.com:AtaraxiaDev/pass.git";
    sshKey = config.sops.secrets.git-ssh-key.path;
  };

  persist.derivative.homeDirectories = [ ".local/share/password-store" ];
}