{
  dns-mapping = {
    customDNS = {
      mapping = {
        "coturn.pve" = "192.168.0.20";
        "matrix.pve" = "192.168.0.11";
        "monero.pve" = "192.168.0.13";
        "nginx.pve" = "192.168.0.10";
        "pihole.pve" = "192.168.0.5";
        "proxmox.pve" = "192.168.0.10";
        "sd.ataraxiadev.com" = "192.168.0.100";
        "static.powernet.com.ru" = "10.200.201.167";
        "tinyproxy.pve" = "192.168.0.9";
        "wg.ataraxiadev.com" = "193.219.97.142";
      };
    };
    conditional = {
      mapping = { "pve" = "127.0.0.1"; };
      rewrite = {
        "api.ataraxiadev.com" = "ataraxiadev.com";
        "ataraxiadev.com" = "nginx.pve";
        "auth.ataraxiadev.com" = "ataraxiadev.com";
        "bathist.ataraxiadev.com" = "bathist.ataraxiadev.com";
        "browser.ataraxiadev.com" = "ataraxiadev.com";
        "cache.ataraxiadev.com" = "ataraxiadev.com";
        "cinny.ataraxiadev.com" = "matrix.ataraxiadev.com";
        "cocalc.ataraxiadev.com" = "ataraxiadev.com";
        "code.ataraxiadev.com" = "ataraxiadev.com";
        "dimension.ataraxiadev.com" = "matrix.ataraxiadev.com";
        "element.ataraxiadev.com" = "matrix.ataraxiadev.com";
        "fb.ataraxiadev.com" = "ataraxiadev.com";
        "file.ataraxiadev.com" = "ataraxiadev.com";
        "fsync.ataraxiadev.com" = "ataraxiadev.com";
        "goneb.ataraxiadev.com" = "matrix.ataraxiadev.com";
        "home.ataraxiadev.com" = "ataraxiadev.com";
        "jackett.ataraxiadev.com" = "ataraxiadev.com";
        "jellyfin.ataraxiadev.com" = "ataraxiadev.com";
        "jitsi.ataraxiadev.com" = "matrix.ataraxiadev.com";
        "joplin.ataraxiadev.com" = "ataraxiadev.com";
        "kavita.ataraxiadev.com" = "ataraxiadev.com";
        "ldap.ataraxiadev.com" = "ataraxiadev.com";
        "mail.ataraxiadev.com" = "ataraxiadev.com";
        "matrix.ataraxiadev.com" = "nginx.pve";
        "medusa.ataraxiadev.com" = "ataraxiadev.com";
        "microbin.ataraxiadev.com" = "ataraxiadev.com";
        "nzbhydra.ataraxiadev.com" = "ataraxiadev.com";
        "openbooks.ataraxiadev.com" = "ataraxiadev.com";
        "organizr.ataraxiadev.com" = "ataraxiadev.com";
        "prowlarr.ataraxiadev.com" = "ataraxiadev.com";
        "qbit.ataraxiadev.com" = "ataraxiadev.com";
        "radarr.ataraxiadev.com" = "ataraxiadev.com";
        "restic.ataraxiadev.com" = "ataraxiadev.com";
        "shoko.ataraxiadev.com" = "ataraxiadev.com";
        "sonarr.ataraxiadev.com" = "ataraxiadev.com";
        "sonarrtv.ataraxiadev.com" = "ataraxiadev.com";
        "startpage.ataraxiadev.com" = "ataraxiadev.com";
        "stats.ataraxiadev.com" = "matrix.ataraxiadev.com";
        "tools.ataraxiadev.com" = "ataraxiadev.com";
        "turn.ataraxiadev.com" = "coturn.pve";
        "vw.ataraxiadev.com" = "ataraxiadev.com";
        "webmail.ataraxiadev.com" = "ataraxiadev.com";
        "www.ataraxiadev.com" = "ataraxiadev.com";
      };
    };
  };
}
