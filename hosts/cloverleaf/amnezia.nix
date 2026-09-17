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
    address = [ "10.10.61.1/24" ];
    listenPort = 443;
    privateKeyFile = config.sops.secrets."awg-server-priv".path;
    mtu = 1280;
    type = "amneziawg";
    extraOptions = {
      S1 = "57";
      S2 = "50";
      S3 = "17";
      S4 = "28";
      H1 = "723130143-723159702";
      H2 = "1504900640-1504940380";
      H3 = "2829293370-2829326215";
      H4 = "3909368891-3909390939";
      HeaderProtectionKey = "jMRcJCnjQhjpUCZfUxdUmAonWzdCrU8aJZcT3U1usII=";
      ContentPaddingAddition = "61-78";
      RekeyAfterTime = "103-114";
      RekeyTimeout = "5-6";
      RejectAfterTime = "170-191";
      KeepaliveTimeout = "8-15";
      MaxHandshakeAttempts = "14-19";
    };
    peers = [
      {
        # homelab - 10.10.61.2/32
        publicKey = "kfG/J0l/UbKbGNuJZEdG8ZSCPEdSg+W4pt8ptgQEF1U=";
        presharedKeyFile = config.sops.secrets."awg-homelab-psk".path;
        allowedIPs = [ "10.10.61.2/32" ];
      }
      {
        # homelab-warp - 10.10.61.102/32
        publicKey = "YgyTumJ7d9tV3J+r1++FFVVW8qyIMQlU1nfa4KJjVxo=";
        presharedKeyFile = config.sops.secrets."awg-homelab-warp-psk".path;
        allowedIPs = [ "10.10.61.102/32" ];
      }
      {
        # ataraxia-podkop - 10.10.61.3/32
        publicKey = "ioalVRNHu1t4Vrhn9aFrPiuGqe4CvMXYBCgabH/L7G0=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-podkop-psk".path;
        allowedIPs = [ "10.10.61.3/32" ];
      }
      {
        # ataraxia-podkop-warp - 10.10.61.103/32
        publicKey = "YvDV+Myo1VMmM/U8bNU+7a3EilpSoSX51BY8evW4oEY=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-podkop-warp-psk".path;
        allowedIPs = [ "10.10.61.103/32" ];
      }
      {
        # ataraxia - 10.10.61.4/32
        publicKey = "32CnOHDSw8YvlGBnnZ1dWiTpjG6jKPV/fsHO0kFBBAM=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-psk".path;
        allowedIPs = [ "10.10.61.4/32" ];
      }
      {
        # ataraxia-warp - 10.10.61.104/32
        publicKey = "FQqqmwUklx4wzBYOlIhVJRRqOjz0qI2QVmktwKFGizw=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-warp-psk".path;
        allowedIPs = [ "10.10.61.104/32" ];
      }
      {
        # ataraxia-laptop - 10.10.61.5/32
        publicKey = "kie5dOV/31Fi+JUkJptOupnUoW2ZYwUQt33myoo7O3A=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-laptop-psk".path;
        allowedIPs = [ "10.10.61.5/32" ];
      }
      {
        # ataraxia-laptop-warp - 10.10.61.105/32
        publicKey = "Tm+yICxVHh8Oh85yRNQlnsCi+7lb2sRxkWmjGQwDlQ8=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-laptop-warp-psk".path;
        allowedIPs = [ "10.10.61.105/32" ];
      }
      {
        # ataraxia-phone - 10.10.61.6/32
        publicKey = "ef1vUibCbk1FUvOmxQH7n2wEq58LN7FLa4n4fu7UWTk=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-phone-psk".path;
        allowedIPs = [ "10.10.61.6/32" ];
      }
      {
        # ataraxia-phone-warp - 10.10.61.106/32
        publicKey = "oL+BfwD667iYIjPzy1sywQEKZPpR/Hf41oiCUGUO2CY=";
        presharedKeyFile = config.sops.secrets."awg-ataraxia-phone-warp-psk".path;
        allowedIPs = [ "10.10.61.106/32" ];
      }
      {
        # kpoxa - 10.10.61.7/32
        publicKey = "teT8bRLy46ujCLNaCjRat69WuYN3qsVtX19injmzEh4=";
        presharedKeyFile = config.sops.secrets."awg-kpoxa-psk".path;
        allowedIPs = [ "10.10.61.7/32" ];
      }
      {
        # kpoxa-warp - 10.10.61.107/32
        publicKey = "plaWOE9f7t8K3URVfxri6jtHd6jTtoQ1+AC/+FWjGCQ=";
        presharedKeyFile = config.sops.secrets."awg-kpoxa-warp-psk".path;
        allowedIPs = [ "10.10.61.107/32" ];
      }
      {
        # kpoxa-phone - 10.10.61.8/32
        publicKey = "tthgooPlNTAQDYb6JIUczECmAXEfWdNvV3SMLTXXmyU=";
        presharedKeyFile = config.sops.secrets."awg-kpoxa-phone-psk".path;
        allowedIPs = [ "10.10.61.8/32" ];
      }
      {
        # kpoxa-phone-warp - 10.10.61.108/32
        publicKey = "nHSKzfb5El0UBFeKb2dm1RTPLNXTZ2QaETTTmHsBlko=";
        presharedKeyFile = config.sops.secrets."awg-kpoxa-phone-warp-psk".path;
        allowedIPs = [ "10.10.61.108/32" ];
      }
      {
        # oleg - 10.10.61.9/32
        publicKey = "juIMEkbKwTQbaWVN/t/iknw72MZtqFlYp9JGmITzckI=";
        presharedKeyFile = config.sops.secrets."awg-oleg-psk".path;
        allowedIPs = [ "10.10.61.9/32" ];
      }
      {
        # oleg-warp - 10.10.61.109/32
        publicKey = "RXUH0kIklsc3SXakcSNTi0Wyxp4vfQKP8IK5YY7eVjU=";
        presharedKeyFile = config.sops.secrets."awg-oleg-warp-psk".path;
        allowedIPs = [ "10.10.61.109/32" ];
      }
      {
        # oleg-podkop - 10.10.61.10/32
        publicKey = "jlrCdPfPwb6CUEQVfcRmKnD3UtJN4B6W+1RPlDwIEng=";
        presharedKeyFile = config.sops.secrets."awg-oleg-podkop-psk".path;
        allowedIPs = [ "10.10.61.10/32" ];
      }
      {
        # oleg-podkop-warp - 10.10.61.110/32
        publicKey = "wFkbFxHGNo/8JsWWGfTkGaGCjZE22+MAPwufCo9GOzI=";
        presharedKeyFile = config.sops.secrets."awg-oleg-podkop-warp-psk".path;
        allowedIPs = [ "10.10.61.110/32" ];
      }
      {
        # vlad-pc - 10.10.61.11/32
        publicKey = "aPoCsJXlBTuGtVE6EaFi+ZTxXFHfNcYXara6JIu6kSM=";
        presharedKeyFile = config.sops.secrets."awg-vlad-pc-psk".path;
        allowedIPs = [ "10.10.61.11/32" ];
      }
      {
        # vlad-pc-warp - 10.10.61.111/32
        publicKey = "Ex1eULLMe/w8VoK8p6mFmRryLMALZ6BQ0GMJ31uowBU=";
        presharedKeyFile = config.sops.secrets."awg-vlad-pc-warp-psk".path;
        allowedIPs = [ "10.10.61.111/32" ];
      }
      {
        # vlad-laptop - 10.10.61.12/32
        publicKey = "po4aw4K64mK2PxTkXv3VvYV/XQdG59IArlM/INgBMy0=";
        presharedKeyFile = config.sops.secrets."awg-vlad-laptop-psk".path;
        allowedIPs = [ "10.10.61.12/32" ];
      }
      {
        # vlad-laptop-warp - 10.10.61.112/32
        publicKey = "jNM0uDmeE4paEf7odc4dzdIp87keU2b9T3DGOf/1ISE=";
        presharedKeyFile = config.sops.secrets."awg-vlad-laptop-warp-psk".path;
        allowedIPs = [ "10.10.61.112/32" ];
      }
      {
        # vlad-phone - 10.10.61.13/32
        publicKey = "ThrMe3GAIx6y2VjDjXMFh8oAGHaEKyUi4+jArykfZRU=";
        presharedKeyFile = config.sops.secrets."awg-vlad-phone-psk".path;
        allowedIPs = [ "10.10.61.13/32" ];
      }
      {
        # vlad-phone-warp - 10.10.61.113/32
        publicKey = "PlLgYLiAr74sgMFA5rEAmcDdFVuk3MR2y2e1ARkKLxo=";
        presharedKeyFile = config.sops.secrets."awg-vlad-phone-warp-psk".path;
        allowedIPs = [ "10.10.61.113/32" ];
      }
      {
        # katya-phone - 10.10.61.14/32
        publicKey = "779GzQndjxx+bLtiVwJPn6ALuFW4oXKp048JcenwqEg=";
        presharedKeyFile = config.sops.secrets."awg-katya-phone-psk".path;
        allowedIPs = [ "10.10.61.14/32" ];
      }
      {
        # katya-phone-warp - 10.10.61.114/32
        publicKey = "W4rUCh4npWNVngFAw/xCwkF9ACSRsZ/+WMNxPY9qzHQ=";
        presharedKeyFile = config.sops.secrets."awg-katya-phone-warp-psk".path;
        allowedIPs = [ "10.10.61.114/32" ];
      }
      {
        # kirill - 10.10.61.15/32
        publicKey = "RJe/zmWg4q/33WPlbdIRSDFqCLMvlJwgpXXIfBY13UA=";
        presharedKeyFile = config.sops.secrets."awg-kirill-psk".path;
        allowedIPs = [ "10.10.61.15/32" ];
      }
      {
        # kirill-warp - 10.10.61.115/32
        publicKey = "zxZdN0NoBE9R6LNvV2+zfwWmMYZuxgP4J/lNGXPqW1U=";
        presharedKeyFile = config.sops.secrets."awg-kirill-warp-psk".path;
        allowedIPs = [ "10.10.61.115/32" ];
      }
      {
        # elya - 10.10.61.16/32
        publicKey = "D/22NN7M/Ofdr6pd6qD04JgVbiR88jcmyj/dfjUtL0w=";
        presharedKeyFile = config.sops.secrets."awg-elya-psk".path;
        allowedIPs = [ "10.10.61.16/32" ];
      }
      {
        # elya-warp - 10.10.61.116/32
        publicKey = "4VSy+7JsDwTOZsdfgXrNH48KfdvpEjYiwJaxzJ04n3Y=";
        presharedKeyFile = config.sops.secrets."awg-elya-warp-psk".path;
        allowedIPs = [ "10.10.61.116/32" ];
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
        ip saddr 10.10.61.0/24 oifname "${oifname}" masquerade
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
