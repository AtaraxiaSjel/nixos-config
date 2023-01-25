{ fetchFromGitHub
, pkg-config
, stdenv
, autoreconfHook
, lib
# Package dependencies
, libsearpc
, libselinux
, libuuid
, pcre
, libtool
, libevent
, sqlite
, openssl
, fuse
, vala
, intltool
, jansson
, curl
, python
}:

stdenv.mkDerivation rec {
  pname = "seadrive-fuse";
  version = "2.0.16";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = pname;
    rev = "v${version}";
    sha256 = "072sx4wvj3gbslv3hn4sifr28fy812b8aja9d7phl1w4yix9l55z";
  };

  patches = [];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = [
    libsearpc
    libselinux
    libuuid # Satisfies the 'mount' package requirement. Contains 'mount.pc'
    pcre
    libtool
    libevent
    sqlite
    openssl.dev
    fuse
    vala
    intltool
    jansson
    curl
    python
  ];

  meta = with lib; {
    homepage = "https://github.com/haiwen/seadrive-fuse";
    description = "SeaDrive daemon with FUSE interface";
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [];
  };
}
