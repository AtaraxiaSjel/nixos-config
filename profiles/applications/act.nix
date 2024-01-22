{ config, pkgs, inputs, ... }: {
  sops.secrets.github-token.sopsFile = inputs.self.secretsDir + /amd-workstation/misc.yaml;
  sops.secrets.github-token.owner = config.mainuser;

  home-manager.users.${config.mainuser} = {
    home.packages = [ pkgs.act ];
    home.file.".actrc".text = ''
      --secret-file ${config.sops.secrets.github-token.path}
      -P ubuntu-latest=catthehacker/ubuntu:act-latest
      -P ubuntu-22.04=catthehacker/ubuntu:act-22.04
    '';
  };
}
