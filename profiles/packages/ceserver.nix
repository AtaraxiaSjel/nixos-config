{ stdenv, fetchFromGitHub, zlib }:

 stdenv.mkDerivation rec {
  pname = "ceserver";
  version = "7.3";

  src = fetchFromGitHub {
    owner = "cheat-engine";
    repo = "cheat-engine";
    rev = version;
    sha256 = "1f7v2403k2hq8mx3lwdlssfmbmj3kjnhljk5qfzgqyygwz72zqhl";
    # fetchSubmodules = true;
  };

  buildPhase = ''
    cd Cheat\ Engine/ceserver/gcc
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ceserver $out/bin
  '';

  nativeBuildInputs = [
    zlib
  ];
  buildInputs = [

  ];
}
