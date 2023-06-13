{ config, pkgs, ... }: {
  secrets.github-token.owner = config.mainuser;

  home-manager.users.${config.mainuser} = {
    home.packages = [ pkgs.act ];
    home.file.".actrc".text = ''
      --secret-file ${config.secrets.github-token.decrypted}
      -P ubuntu-latest=catthehacker/ubuntu:act-latest
      -P ubuntu-22.04=catthehacker/ubuntu:act-22.04
    '';
  };
}
