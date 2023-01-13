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
      # "bogons.cymru.com"
      # "cbl.abuseat.org"
      # "combined.abuse.ch"
      # "db.wpbl.info"
      # "dnsbl-1.uceprotect.net"
      # "dnsbl-2.uceprotect.net"
      # "dnsbl-3.uceprotect.net"
      # "dnsbl.anticaptcha.net"
      # "dnsbl.dronebl.org"
      # "dnsbl.inps.de"
      # "dnsbl.sorbs.net"
      # "dnsbl.spfbl.net"
      # "drone.abuse.ch"
      # "duinv.aupads.org"
      # "dul.dnsbl.sorbs.net"
      # "dyna.spamrats.com"
      # "dynip.rothen.com"
      # "http.dnsbl.sorbs.net"
      # "ips.backscatterer.org"
      # "ix.dnsbl.manitu.net"
      # "korea.services.net"
      # "misc.dnsbl.sorbs.net"
      # "noptr.spamrats.com"
      # "orvedb.aupads.org"
      # "pbl.spamhaus.org"
      # "proxy.bl.gweep.ca"
      # "psbl.surriel.com"
      # "relays.bl.gweep.ca"
      # "relays.nether.net"
      # "sbl.spamhaus.org"
      # "singular.ttk.pte.hu"
      # "smtp.dnsbl.sorbs.net"
      # "socks.dnsbl.sorbs.net"
      # "spam.abuse.ch"
      # "spam.dnsbl.anonmails.de"
      # "spam.dnsbl.sorbs.net"
      # "spam.spamrats.com"
      # "spambot.bls.digibase.ca"
      # "spamrbl.imp.ch"
      # "spamsources.fabel.dk"
      # "ubl.lashback.com"
      # "ubl.unsubscore.com"
      # "virus.rbl.jp"
      # "web.dnsbl.sorbs.net"
      # "wormrbl.imp.ch"
      # "xbl.spamhaus.org"
      # "z.mailspike.net"
      # "zen.spamhaus.org"
      # "zombie.dnsbl.sorbs.net"
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

      "gitea@ataraxiadev.com" = {
        aliases = [ "gitea" ];
        hashedPasswordFile = config.secrets.mailserver-gitea.decrypted;
      };
      "joplin@ataraxiadev.com" = {
        aliases = [ "joplin" ];
        hashedPasswordFile = config.secrets.mailserver-joplin.decrypted;
      };
      "vaultwarden@ataraxiadev.com" = {
        aliases = [ "vaultwarden" ];
        hashedPasswordFile = config.secrets.mailserver-vaultwarden.decrypted;
      };
      "seafile@ataraxiadev.com" = {
        aliases = [ "seafile" ];
        hashedPasswordFile = config.secrets.mailserver-seafile.decrypted;
      };
    };
    hierarchySeparator = "/";
    localDnsResolver = true;
    # certificateScheme = 3;
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
  ] ++ lib.optionals (config.deviceSpecific.devInfo.fileSystem != "zfs") [
    config.mailserver.dkimKeyDirectory
    config.mailserver.mailDirectory
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}