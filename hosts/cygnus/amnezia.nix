{
  config,
  pkgs,
  secretsDir,
  ...
}:
let

  networkd = config.ataraxia.networkd;
  oifname = if networkd.bridge.enable then networkd.bridge.name else networkd.ifname;
  awg-listen-port = 443;
  awg-sops = {
    sopsFile = secretsDir + /${config.networking.hostName}/awg.yaml;
  };
in
{
  boot.kernelModules = [ "amneziawg" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ amneziawg ];
  environment.systemPackages = [ pkgs.amneziawg-tools ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv4.conf.all.src_valid_mark" = "1";
  };

  networking.wg-quick.interfaces.awg0 = {
    address = [ "10.10.60.1/24" ];
    listenPort = 443;
    privateKeyFile = config.sops.secrets."awg-server-priv".path;
    mtu = 1280;
    type = "amneziawg";
    extraOptions = {
      S1 = "81";
      S2 = "128";
      S3 = "57";
      S4 = "18";
      H1 = "768841381-768857218";
      H2 = "1306356563-1306398265";
      H3 = "2627374337-2627380024";
      H4 = "3746258080-3746286463";
      HeaderProtectionKey = "0oEbqi1MQi5osXFYrR2kVgZtKxNJk3JdURChCgx4qRI=";
      ContentPaddingAddition = "61-125";
      RekeyAfterTime = "103-126";
      RekeyTimeout = "4-8";
      RejectAfterTime = "170-186";
      KeepaliveTimeout = "14-21";
      MaxHandshakeAttempts = "14-16";
    };
    peers = [
      {
        # homelab - 10.10.60.2/32
        publicKey = "m4qLD5vEWxUeR+kbpAkm5fLLKKVtZ1jVRoMaIPvhwSc=";
        presharedKeyFile = config.sops.secrets."awg-homelab-psk".path;
        allowedIPs = [ "10.10.60.2/32" ];
      }
      {
        # homelab-warp - 10.10.60.102/32
        publicKey = "ixEaZC2iaUekR8MTTpc92ACE7qgbc6W0zPgKNFlmjW4=";
        presharedKeyFile = config.sops.secrets."awg-homelab-warp-psk".path;
        allowedIPs = [ "10.10.60.102/32" ];
      }
      {
        # ataraxia-podkop - 10.10.60.3/32
        publicKey = "8bqJ/oBwB0kgj8svQUEzY5C67ftfZcSsyywDH8ZIsSo=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-podkop-psk".path;
        allowedIPs = [ "10.10.60.3/32" ];
      }
      {
        # ataraxia-podkop-warp - 10.10.60.103/32
        publicKey = "yVIQSAgcF9zLUu29i12N+H+HyHTjmPRtPj5497q6w0M=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-podkop-warp-psk".path;
        allowedIPs = [ "10.10.60.103/32" ];
      }
      {
        # ataraxia - 10.10.60.4/32
        publicKey = "5YENnY+fsTQtmB0TKvrHrd0jkJxSSTOK4lbeWxMSin8=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-psk".path;
        allowedIPs = [ "10.10.60.4/32" ];
      }
      {
        # ataraxia-warp - 10.10.60.104/32
        publicKey = "RD1CH1raFnkKUsesOR7MWwnJ9n3rLIbucwP3xnM820c=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-warp-psk".path;
        allowedIPs = [ "10.10.60.104/32" ];
      }
      {
        # ataraxia-laptop - 10.10.60.5/32
        publicKey = "B2hK6fEfh5P1tjkvQ4BoCZj7jd6L4J21LzHqcSfxJko=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-laptop-psk".path;
        allowedIPs = [ "10.10.60.5/32" ];
      }
      {
        # ataraxia-laptop-warp - 10.10.60.105/32
        publicKey = "zh7LmmFsZUa7EkiEJ5OsRFH2qsSfpKWwMeumfTTjb3Y=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-laptop-warp-psk".path;
        allowedIPs = [ "10.10.60.105/32" ];
      }
      {
        # ataraxia-phone - 10.10.60.6/32
        publicKey = "auKgXPgTMFO/Yr9P1G8Y74GtWvbV9uxf9uKYzgr6pEE=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-phone-psk".path;
        allowedIPs = [ "10.10.60.6/32" ];
      }
      {
        # ataraxia-phone-warp - 10.10.60.106/32
        publicKey = "zQqyOTCHYRdqRBnDetDKtPA890Xmdm8PpIRNwDdhVF0=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-phone-warp-psk".path;
        allowedIPs = [ "10.10.60.106/32" ];
      }
      {
        # kpoxa - 10.10.60.7/32
        publicKey = "GvaVPqlOZbvMt/AnxwKxFH/PBSHXoM8Nkh4dCUb2wjE=";
        presharedKeyFile = config.sops.secrets."awg-kpoxa-psk".path;
        allowedIPs = [ "10.10.60.7/32" ];
      }
      {
        # kpoxa-warp - 10.10.60.107/32
        publicKey = "suV69ZjF4oNsKR4hhA2MlzHrmXHLEQssCT81hQXuH2Y=";
        presharedKeyFile = config.sops.secrets."awg-kpoxa-warp-psk".path;
        allowedIPs = [ "10.10.60.107/32" ];
      }
      {
        # kpoxa-phone - 10.10.60.8/32
        publicKey = "HGwDaW0YRULQgkANya6l3L+6m9P3og6MOFM1SkXyd2I=";
        presharedKeyFile = config.sops.secrets."awg-kpoxa-phone-psk".path;
        allowedIPs = [ "10.10.60.8/32" ];
      }
      {
        # kpoxa-phone-warp - 10.10.60.108/32
        publicKey = "VpEAJGd7gA/UX69CFlJ12/qwah1VmG6YAq5LitGIUmQ=";
        presharedKeyFile = config.sops.secrets."awg-kpoxa-phone-warp-psk".path;
        allowedIPs = [ "10.10.60.108/32" ];
      }
      {
        # oleg - 10.10.60.9/32
        publicKey = "P1Dhg7KFR5N3/Htor8tniXS5LN68k1NVEg3BVTshJ10=";
        presharedKeyFile = config.sops.secrets."awg-oleg-psk".path;
        allowedIPs = [ "10.10.60.9/32" ];
      }
      {
        # oleg-warp - 10.10.60.109/32
        publicKey = "K+tKs91nc/SY7owVjV3NgfZSZeCSaW+6GL6B3Nh8HU4=";
        presharedKeyFile = config.sops.secrets."awg-oleg-warp-psk".path;
        allowedIPs = [ "10.10.60.109/32" ];
      }
      {
        # oleg-podkop - 10.10.60.10/32
        publicKey = "Yidz4iPNjE5DJy3eS/nM7aIxCZSVIVQyjPwTR+ZwDHU=";
        presharedKeyFile = config.sops.secrets."awg-oleg-podkop-psk".path;
        allowedIPs = [ "10.10.60.10/32" ];
      }
      {
        # oleg-podkop-warp - 10.10.60.110/32
        publicKey = "/H2fFDnwpGVbm4sgyihOYgMJPLcmyw2i0ochBWoK6H0=";
        presharedKeyFile = config.sops.secrets."awg-oleg-podkop-warp-psk".path;
        allowedIPs = [ "10.10.60.110/32" ];
      }
      {
        # vlad-pc - 10.10.60.11/32
        publicKey = "B17w/8p6cb4mIlYDon9JViMIuzhpFK43TtiC494liHY=";
        presharedKeyFile = config.sops.secrets."awg-vlad-pc-psk".path;
        allowedIPs = [ "10.10.60.11/32" ];
      }
      {
        # vlad-pc-warp - 10.10.60.111/32
        publicKey = "nYcp5KI8I89mSDRKvtI5u5EKuOQ6cTf5v4U2nv8JbG0=";
        presharedKeyFile = config.sops.secrets."awg-vlad-pc-warp-psk".path;
        allowedIPs = [ "10.10.60.111/32" ];
      }
      {
        # vlad-laptop - 10.10.60.12/32
        publicKey = "E37hpKmT115ikCo0amEixaja+MGqBeppYb7cjBhf/Ws=";
        presharedKeyFile = config.sops.secrets."awg-vlad-laptop-psk".path;
        allowedIPs = [ "10.10.60.12/32" ];
      }
      {
        # vlad-laptop-warp - 10.10.60.112/32
        publicKey = "EnsV8h8q3WC/NePC2kKk8DlmWd0HTB4jkh73QBvYFQo=";
        presharedKeyFile = config.sops.secrets."awg-vlad-laptop-warp-psk".path;
        allowedIPs = [ "10.10.60.112/32" ];
      }
      {
        # vlad-phone - 10.10.60.13/32
        publicKey = "Xy5RgEeRsFjrpqNG0/nwi94F677LEE5lK25sInj2WnQ=";
        presharedKeyFile = config.sops.secrets."awg-vlad-phone-psk".path;
        allowedIPs = [ "10.10.60.13/32" ];
      }
      {
        # vlad-phone-warp - 10.10.60.113/32
        publicKey = "sOmvXmb25KpgrZp9dDrV1coV0URrtOPIQSZhjfwLTVU=";
        presharedKeyFile = config.sops.secrets."awg-vlad-phone-warp-psk".path;
        allowedIPs = [ "10.10.60.113/32" ];
      }
      {
        # katya-phone - 10.10.60.14/32
        publicKey = "slCQGQW9i/tsaFVeWrZ8r+ahvL24QQkea7E7JPSdrDM=";
        presharedKeyFile = config.sops.secrets."awg-katya-phone-psk".path;
        allowedIPs = [ "10.10.60.14/32" ];
      }
      {
        # katya-phone-warp - 10.10.60.114/32
        publicKey = "Wt/13QTuw8k9KV5twsOqY9EnUeg7060nYaJ3YHAvlmI=";
        presharedKeyFile = config.sops.secrets."awg-katya-phone-warp-psk".path;
        allowedIPs = [ "10.10.60.114/32" ];
      }
      {
        # kirill - 10.10.60.15/32
        publicKey = "5Z3sst0YwFLlC3MNr+DQZCH1nzdsoA6uldAvG6IdYzo=";
        presharedKeyFile = config.sops.secrets."awg-kirill-psk".path;
        allowedIPs = [ "10.10.60.15/32" ];
      }
      {
        # kirill-warp - 10.10.60.115/32
        publicKey = "JxgGFhz+vkq1vs+BIZy99Iim8T47/ErvAIA6lvpHWWE=";
        presharedKeyFile = config.sops.secrets."awg-kirill-warp-psk".path;
        allowedIPs = [ "10.10.60.115/32" ];
      }
      {
        # elya - 10.10.60.16/32
        publicKey = "cPxgc9/AIOh1/o3Tkp6A1viyoeyBJR9gDXGbVAFKLik=";
        presharedKeyFile = config.sops.secrets."awg-elya-psk".path;
        allowedIPs = [ "10.10.60.16/32" ];
      }
      {
        # elya-warp - 10.10.60.116/32
        publicKey = "TZG4gJ6DOsD6QDDXMrlTr8I5Rn9tRjgYcwPunNO/vyg=";
        presharedKeyFile = config.sops.secrets."awg-elya-warp-psk".path;
        allowedIPs = [ "10.10.60.116/32" ];
      }
    ];
  };

  sops.secrets."awg-server-priv" = awg-sops;
  sops.secrets."awg-homelab-psk" = awg-sops;
  sops.secrets."awg-homelab-warp-psk" = awg-sops;
  sops.secrets."awg-ataraxia-podkop-psk" = awg-sops;
  sops.secrets."awg-ataraxia-podkop-warp-psk" = awg-sops;
  sops.secrets."awg-ataraxia-psk" = awg-sops;
  sops.secrets."awg-ataraxia-warp-psk" = awg-sops;
  sops.secrets."awg-ataraxia-laptop-psk" = awg-sops;
  sops.secrets."awg-ataraxia-laptop-warp-psk" = awg-sops;
  sops.secrets."awg-ataraxia-phone-psk" = awg-sops;
  sops.secrets."awg-ataraxia-phone-warp-psk" = awg-sops;
  sops.secrets."awg-kpoxa-psk" = awg-sops;
  sops.secrets."awg-kpoxa-warp-psk" = awg-sops;
  sops.secrets."awg-kpoxa-phone-psk" = awg-sops;
  sops.secrets."awg-kpoxa-phone-warp-psk" = awg-sops;
  sops.secrets."awg-oleg-psk" = awg-sops;
  sops.secrets."awg-oleg-warp-psk" = awg-sops;
  sops.secrets."awg-oleg-podkop-psk" = awg-sops;
  sops.secrets."awg-oleg-podkop-warp-psk" = awg-sops;
  sops.secrets."awg-vlad-pc-psk" = awg-sops;
  sops.secrets."awg-vlad-pc-warp-psk" = awg-sops;
  sops.secrets."awg-vlad-laptop-psk" = awg-sops;
  sops.secrets."awg-vlad-laptop-warp-psk" = awg-sops;
  sops.secrets."awg-vlad-phone-psk" = awg-sops;
  sops.secrets."awg-vlad-phone-warp-psk" = awg-sops;
  sops.secrets."awg-katya-phone-psk" = awg-sops;
  sops.secrets."awg-katya-phone-warp-psk" = awg-sops;
  sops.secrets."awg-kirill-psk" = awg-sops;
  sops.secrets."awg-kirill-warp-psk" = awg-sops;
  sops.secrets."awg-elya-psk" = awg-sops;
  sops.secrets."awg-elya-warp-psk" = awg-sops;

  networking.nftables.ruleset = ''
    table ip awg_nat {
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 10.10.60.0/24 oifname "${oifname}" masquerade
      }
    }
    table ip awg_filter {
      chain forward {
        type filter hook forward priority filter; policy accept;
        ct state established,related accept
        iifname "awg0" accept
        oifname "awg0" accept
      }
    }
  '';

  networking.firewall.allowedUDPPorts = [ awg-listen-port ];

  systemd.tmpfiles.rules = [ "d /srv/amneziawg 0700 root root -" ];
}
