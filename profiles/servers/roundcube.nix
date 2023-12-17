{ config, lib, pkgs, ... }: {
  services.roundcube = {
    enable = true;
    database.username = "roundcube";
    dicts = with pkgs.aspellDicts; [ en ru ];
    extraConfig = ''
      $config['imap_host'] = array(
        'tls://mail.ataraxiadev.com' => "AtaraxiaDev's Mail Server",
        'ssl://imap.gmail.com:993' => 'Google Mail',
      );
      $config['username_domain'] = array(
        'mail.ataraxiadev.com' => 'ataraxiadev.com',
        'mail.gmail.com' => 'gmail.com',
      );
      $config['x_frame_options'] = false;
      $config['smtp_host'] = "tls://mail.ataraxiadev.com:587";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
    hostName = "webmail.ataraxiadev.com";
    maxAttachmentSize = 50;
    plugins = [ "carddav" "persistent_login" "managesieve" ];
    package = pkgs.roundcube.withPlugins (plugins:
      with plugins; [ carddav persistent_login ]
    );
  };

  services.phpfpm.pools.roundcube.settings = {
    "listen.owner" = config.services.nginx.user;
    "listen.group" = config.services.nginx.group;
  };

  persist.state.directories = [ "/var/lib/roundcube" ];
}