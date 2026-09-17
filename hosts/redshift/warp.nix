{
  config,
  secretsDir,
  lib,
  ...
}:
let
  isIPv6 = !config.ataraxia.networkd.disableIPv6;
  awg-sops = {
    sopsFile = secretsDir + /${config.networking.hostName}/awg.yaml;
  };
  warpTable = "100";
  warpMark = "51";
in
{
  networking.wg-quick.interfaces.warp0 = {
    type = "wireguard";
    mtu = 1280;
    dns = [
      "9.9.9.11"
      "1.1.1.1"
      "1.0.0.1"
    ]
    ++ lib.optionals isIPv6 [
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
    address = [
      "172.16.0.2/32"
    ]
    ++ lib.optionals isIPv6 [
      "2606:4700:110:8c3c:8686:8cbe:8f77:3c2b/128"
    ];
    privateKeyFile = config.sops.secrets."warp-priv".path;
    extraOptions.Table = warpTable;
    peers = [
      {
        publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
        endpoint = "162.159.192.102:2408";
        allowedIPs = [
          "0.0.0.0/0"
        ]
        ++ lib.optionals isIPv6 [
          "::/0"
        ];
      }
    ];
    postUp = "ip rule add fwmark ${warpMark} table ${warpTable} priority 1000";
    postDown = "ip rule del fwmark ${warpMark} table ${warpTable} 2>/dev/null || true";
  };
  sops.secrets."warp-priv" = awg-sops;

  networking.nftables.ruleset = lib.mkAfter ''
    table ip mangle {
      chain prerouting {
        type filter hook prerouting priority mangle; policy accept;
        ip saddr 10.10.60.100-10.10.60.199 meta mark set ${warpMark}
      }
    }
    table ip awg_forward_warp {
      chain forward {
        type filter hook forward priority filter; policy accept;
        iifname "awg0" oifname "warp0" accept
        iifname "warp0" oifname "awg0" accept
      }
    }
  '';
}
