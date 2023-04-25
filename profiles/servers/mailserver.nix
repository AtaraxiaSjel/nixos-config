{ pkgs, config, lib, inputs, ... }:
let
  secrets-default = {
    owner = "dovecot2:dovecot2";
    services = [ "dovecot2" ];
  };
in {
  imports = [ (toString inputs.simple-nixos-mailserver) ];
  secrets.mailserver = secrets-default;
  secrets.mailserver-minichka = secrets-default;
  secrets.mailserver-mitin = secrets-default;
  secrets.mailserver-joplin = secrets-default;
  secrets.mailserver-vaultwarden = secrets-default;
  secrets.mailserver-seafile = secrets-default;
  secrets.mailserver-gitea = secrets-default;
  secrets.mailserver-authentik = secrets-default;
  secrets.mailserver-kavita = secrets-default;
  secrets.mailserver-synapse = secrets-default;

  security.acme.certs."mail.ataraxiadev.com" = {
    webroot = "/var/lib/acme/acme-challenge";
    postRun = ''
      systemctl reload postfix
      systemctl reload dovecot2
    '';
  };

  services.postfix = {
    dnsBlacklists = [
      "all.s5h.net"
      "b.barracudacentral.org"
      "bl.spamcop.net"
      "blacklist.woody.ch"
    ];
    dnsBlacklistOverrides = ''
      ataraxiadev.com OK
      mail.ataraxiadev.com OK
      127.0.0.0/8 OK
      192.168.0.0/16 OK
    '';
    headerChecks = [
      {
        action = "IGNORE";
        pattern = "/^User-Agent.*Roundcube Webmail/";
      }
    ];
  };
  mailserver = rec {
    enable = true;
    openFirewall = true;
    fqdn = "mail.ataraxiadev.com";
    domains = [ "ataraxiadev.com" ];
    # hashedPassword:
    # nsp apacheHttpd --run 'htpasswd -nbB "" "super secret password"' | cut -d: -f2
    loginAccounts = {
      "ataraxiadev@ataraxiadev.com" = {
        aliases =[
          "ataraxiadev" "admin@ataraxiadev.com" "admin" "root@ataraxiadev.com" "root"
          "ark@ataraxiadev.com" "ark"
          # "@ataraxiadev.com"
        ];
        hashedPasswordFile = config.secrets.mailserver.decrypted;
      };
      "minichka76@ataraxiadev.com" = {
        aliases =
          [ "minichka76" "kpoxa@ataraxiadev.com" "kpoxa" ];
        hashedPasswordFile = config.secrets.mailserver-minichka.decrypted;
      };
      "mitin@ataraxiadev.com" = {
        aliases = [ "mitin" "mitin1@ataraxiadev.com" "mitin1" "mitin2@ataraxiadev.com" "mitin2" ];
        hashedPasswordFile = config.secrets.mailserver-mitin.decrypted;
      };

      "authentik@ataraxiadev.com" = {
        aliases = [ "authentik" ];
        hashedPasswordFile = config.secrets.mailserver-authentik.decrypted;
      };
      "gitea@ataraxiadev.com" = {
        aliases = [ "gitea" ];
        hashedPasswordFile = config.secrets.mailserver-gitea.decrypted;
      };
      "joplin@ataraxiadev.com" = {
        aliases = [ "joplin" ];
        hashedPasswordFile = config.secrets.mailserver-joplin.decrypted;
      };
      "kavita@ataraxiadev.com" = {
        aliases = [ "kavita" ];
        hashedPasswordFile = config.secrets.mailserver-kavita.decrypted;
      };
      "vaultwarden@ataraxiadev.com" = {
        aliases = [ "vaultwarden" ];
        hashedPasswordFile = config.secrets.mailserver-vaultwarden.decrypted;
      };
      "seafile@ataraxiadev.com" = {
        aliases = [ "seafile" ];
        hashedPasswordFile = config.secrets.mailserver-seafile.decrypted;
      };
      "matrix@ataraxiadev.com" = {
        aliases = [ "matrix" ];
        hashedPasswordFile = config.secrets.mailserver-synapse.decrypted;
      };
    };
    hierarchySeparator = "/";
    localDnsResolver = false;
    certificateScheme = 1;
    certificateFile = "${config.security.acme.certs.${fqdn}.directory}/fullchain.pem";
    keyFile = "${config.security.acme.certs.${fqdn}.directory}/key.pem";
    enableManageSieve = true;
    enableImap = true;
    enableImapSsl = true;
    enablePop3 = false;
    enablePop3Ssl = false;
    enableSubmission = true;
    enableSubmissionSsl = true;
    virusScanning = false;

    mailDirectory = "/srv/mail/vmail";
    dkimKeyDirectory = "/srv/mail/dkim";
  };

  # FIXME: ownership of mail directory
  persist.state.directories = [
    # "/var/lib/dovecot"
    # "/var/lib/postfix"
    # "/var/lib/dhparams"
    "/var/sieve"
  ] ++ lib.optionals (config.deviceSpecific.devInfo.fileSystem != "zfs") [
    config.mailserver.dkimKeyDirectory
    config.mailserver.mailDirectory
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}