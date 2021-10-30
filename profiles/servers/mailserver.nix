{ pkgs, config, lib, inputs, ... }:
let
  module = toString inputs.simple-nixos-mailserver;
in {
  imports = [ module ];
  secrets.mailserver = {
    owner = "dovecot2:cert";
    services = [ "dovecot2" ];
  };
  secrets.sasl_passwd = {
    permissions = "444";
  };

  security.acme = {
    email = "ataraxiadev@ataraxiadev.com";
    acceptTerms = true;
    certs."mail.ataraxiadev.com" = { };
  };

  services.postfix = {
    relayHost = "smtp.email.eu-zurich-1.oci.oraclecloud.com";
    relayPort = 587;
    enableSubmission = true;
    submissionOptions = {
      smtp_tls_security_level = "may";
      smtp_sasl_auth_enable = "yes";
      smtp_sasl_password_maps = "hash:/var/lib/postfix/conf/sasl_passwd";
      smtp_sasl_security_options = "";
    };
    mapFiles = { sasl_passwd = config.secrets.sasl_passwd.decrypted; };
    # dnsBlacklists = [
    #   "all.s5h.net"
    #   "b.barracudacentral.org"
    #   "bl.spamcop.net"
    #   "blacklist.woody.ch"
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
    # ];
    # dnsBlacklistOverrides = ''
    #   ataraxiadev.com OK
    #   192.168.0.0/16 OK
    #   ${lib.concatMapStringsSep "\n" (machine: "${machine}.lan OK") (builtins.attrNames inputs.self.nixosConfigurations)}
    # '';
  };
  mailserver = {
    enable = true;
    openFirewall = true;
    fqdn = "mail.ataraxiadev.com";
    domains = [ "ataraxiadev.com" ];
    loginAccounts = {
      "ataraxiadev@ataraxiadev.com" = {
        aliases =
          [ "ataraxiadev" "admin@ataraxiadev.com" "admin" "root@ataraxiadev.com" "root" ];
        hashedPasswordFile = config.secrets.mailserver.decrypted;
      };
    };
    localDnsResolver = false;
    certificateScheme = 1;
    # certificateFile = config.secrets."ataraxiadev.com.pem".decrypted;
    # keyFile = config.secrets."ataraxiadev.com.key".decrypted;
    enableImap = true;
    enableImapSsl = true;
    virusScanning = false;
  };
}
