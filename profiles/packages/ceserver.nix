{ stdenv, fetchFromGitHub, zlib }:

 stdenv.mkDerivation rec {
  pname = "ceserver";
  version = "7.5";

  src = fetchFromGitHub {
    owner = "cheat-engine";
    repo = "cheat-engine";
    rev = version;
    hash = "sha256-EG2d4iXhBGmVougCi27O27SrC+L3P4alrgnUvBsT1Ic=";
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
