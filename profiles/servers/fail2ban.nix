{ config, ... }: {
  services.openssh.settings.LogLevel = "VERBOSE";

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
      # "8.8.8.8"
    ];
    jails = {
      vaultwarden = ''
        enabled = true
        port = 80,443,8081
        filter = vaultwarden
        banaction = %(banaction_allports)s
        logpath = /var/log/vaultwarden.log
        maxretry = 3
        bantime = 14400
        findtime = 14400
      '';
      vaultwarden-admin = ''
        enabled = true
        port = 80,443
        filter = vaultwarden-admin
        banaction = %(banaction_allports)s
        logpath = /var/log/vaultwarden.log
        maxretry = 3
        bantime = 14400
        findtime = 14400
      '';
    };
  };

  environment.etc."fail2ban/filter.d/vaultwarden.conf" = {
    enable = config.services.vaultwarden.enable;
    text = ''
      [INCLUDES]
      before = common.conf
      [Definition]
      failregex = ^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
      ignoreregex =
    '';
  };

  environment.etc."fail2ban/filter.d/vaultwarden-admin.conf" = {
    enable = config.services.vaultwarden.enable;
    text = ''
      [INCLUDES]
      before = common.conf
      [Definition]
      failregex = ^.*Invalid admin token\. IP: <ADDR>.*$
      ignoreregex =
    '';
  };

  persist.state.directories = [ "/var/lib/fail2ban" ];
}