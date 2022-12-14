{ stdenv, fetchFromGitHub, zlib }:

 stdenv.mkDerivation rec {
  pname = "ceserver";
  version = "7.4";

  src = fetchFromGitHub {
    owner = "cheat-engine";
    repo = "cheat-engine";
    rev = version;
    hash = "sha256-9f4svWpH6kltLQL4w58YPQklLAuLAHMXoVAa4h0jlFk=";
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
}
