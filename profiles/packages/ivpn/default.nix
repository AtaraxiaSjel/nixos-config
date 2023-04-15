{ buildGoModule
, fetchFromGitHub
, lib
, wirelesstools
, makeWrapper
, wireguard-tools
, openvpn
, obfs4
, iproute2
, dnscrypt-proxy2
, iptables
, gawk
, util-linux
}:

builtins.mapAttrs (pname: attrs: buildGoModule (attrs // rec {
  inherit pname;
  version = "3.10.15";

  src = fetchFromGitHub {
    owner = "ivpn";
    repo = "desktop-app";
    rev = "v${version}";
    hash = "sha256-3yVRVM98tVjot3gIkUb/CDwmwKdOOBjBjzGL6htDtpk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ivpn/desktop-app/daemon/version._version=${version}"
    "-X github.com/ivpn/desktop-app/daemon/version._time=1970-01-01"
  ];

  patches = [
    ./path.patch
  ];

  postPatch = ''
    substituteInPlace daemon/service/platform/platform_linux_release.go \
      --replace 'installDir := "/opt/ivpn"' "installDir := \"$out\""
  '';

  postInstall = ''
    mv $out/bin/{${attrs.modRoot},${pname}}
    ${lib.optionalString (attrs.modRoot == "daemon") ''
      install -Dm700 $src/daemon/References/Linux/etc/client.down "$out/etc/client.down"
      install -Dm700 $src/daemon/References/Linux/etc/client.up "$out/etc/client.up"
      install -Dm700 $src/daemon/References/Linux/etc/firewall.sh "$out/etc/firewall.sh"
      install -Dm700 $src/daemon/References/Linux/etc/splittun.sh "$out/etc/splittun.sh"
      install -Dm600 $src/daemon/References/common/etc/servers.json "$out/etc/servers.json"
      install -Dm400 $src/daemon/References/common/etc/ca.crt "$out/etc/ca.crt"
      install -Dm400 $src/daemon/References/common/etc/ta.key "$out/etc/ta.key"
      install -Dm400 $src/daemon/References/common/etc/dnscrypt-proxy-template.toml "$out/etc/dnscrypt-proxy-template.toml"

      patchShebangs --build $out/etc/firewall.sh
      patchShebangs --build $out/etc/splittun.sh
      patchShebangs --build $out/etc/client.down
      patchShebangs --build $out/etc/client.up
    ''}
  '';

  postFixup = lib.optionalString (pname == "ivpn-service") ''
    wrapProgram "$out/bin/ivpn-service" \
      --suffix PATH : ${lib.makeBinPath [
        wireguard-tools
        openvpn
        obfs4
        iproute2
        dnscrypt-proxy2
        iptables
        gawk
        util-linux
      ]}
  '';

  meta = with lib; {
    description = "Official IVPN Desktop app";
    homepage = "https://www.ivpn.net/apps";
    changelog = "https://github.com/ivpn/desktop-app/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ urandom ataraxiasjel ];
  };
})) {
  ivpn = {
    modRoot = "cli";
    vendorHash = "sha256-T49AE3SUmdP3Tu9Sp5C/QryKDto/NzEqRuUQ3+aJFL0=";
  };
  ivpn-service = {
    modRoot = "daemon";
    vendorHash = "sha256-9Rk6ruMpyWtQe+90kw4F8OLq7/JcDSrG6ufkfcrS4W8=";
    buildInputs = [
      wirelesstools
      wireguard-tools
      openvpn
      obfs4
      iproute2
      dnscrypt-proxy2
    ];
  };
}
