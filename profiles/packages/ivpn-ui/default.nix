{ stdenv, lib, fetchurl, dpkg, autoPatchelfHook, makeWrapper
, alsa-lib, at-spi2-atk, at-spi2-core, atk, cairo
, cups, dbus, expat, ffmpeg, gdk-pixbuf, glib
, gtk3, libappindicator, libdrm, libGL, libnotify, libxkbcommon
, mesa, nspr, nss, pango, systemd, xorg, wayland
}:

let deps = [
  alsa-lib
  at-spi2-atk
  at-spi2-core
  atk
  cairo
  cups
  dbus
  expat
  ffmpeg
  gdk-pixbuf
  glib
  gtk3
  libappindicator
  libdrm
  libnotify
  libxkbcommon
  mesa
  nspr
  nss
  pango
  systemd
  xorg.libX11
  xorg.libxcb
  xorg.libXcomposite
  xorg.libXdamage
  xorg.libXext
  xorg.libXfixes
  xorg.libXrandr
]; in
stdenv.mkDerivation rec {
  pname = "ivpn-ui";
  version = "3.10.15";

  src = fetchurl {
    url = "https://repo.ivpn.net/stable/pool/ivpn-ui_${version}_amd64.deb";
    hash = "sha256-dcPxhn+YQbEn1pNgOL8Qtu274Lsnvnwu6Rsyst75W8M=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = deps;

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = "dpkg-deb -x $src .";

  runtimeDependencies = [ (lib.getLib systemd) libGL libnotify libappindicator wayland ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/{ivpn,applications}
    mv opt/ivpn/ui/* $out/share/ivpn
    mv usr/share/* $out/share
    ln -s $out/share/ivpn/bin/ivpn-ui $out/bin

    mv $out/share/ivpn/IVPN.desktop $out/share/applications/IVPN.desktop
    substituteInPlace $out/share/applications/IVPN.desktop \
      --replace "/opt/ivpn/ui/bin/ivpn-ui" "$out/bin/ivpn-ui" \
      --replace "/opt/ivpn/ui/ivpnicon.svg" "$out/share/applications/ivpnicon.svg"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Official IVPN Desktop app";
    homepage = "https://www.ivpn.net/apps";
    changelog = "https://github.com/ivpn/desktop-app/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
