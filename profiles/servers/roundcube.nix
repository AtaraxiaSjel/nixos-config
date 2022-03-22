{ config, lib, pkgs, ... }: {
  secrets.roundcube-db-pass = {
    owner = "roundcube";
  };
  services.roundcube = {
    enable = true;
    database.passwordFile = config.secrets.roundcube-db-pass.decrypted;
    database.username = "roundcube";
    dicts = with pkgs.aspellDicts; [ en ru ];
    extraConfig = ''
      $config['default_host'] = array(
        'tls://mail.ataraxiadev.com' => "AtaraxiaDev's Mail Server"
      );
      $config['username_domain'] = array(
        'mail.ataraxiadev.com' => 'ataraxiadev.com'
      );
    '';
    hostName = "webmail.ataraxiadev.com";
    maxAttachmentSize = 25;
    plugins = [ "carddav" "persistent_login" ];
    package = pkgs.roundcube.withPlugins (plugins:
      with plugins; [ carddav persistent_login ]
    );
  };

  services.phpfpm.pools.roundcube.settings = {
    "listen.owner" = config.services.nginx.user;
    "listen.group" = config.services.nginx.group;
  };
}