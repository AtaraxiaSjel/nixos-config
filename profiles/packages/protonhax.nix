{ stdenv, fetchFromGitHub, tinycc }:

 stdenv.mkDerivation rec {
  pname = "protonhax";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "jcnils";
    repo = pname;
    rev = version;
    hash = "sha256-3s1pmHcQy/xJS6ke0Td3tkXAhXcTuJ4mb3Dtpxb2/6o=";
  };

  buildPhase = ''
    make
  '';

  installPhase = ''
    install -d -m755 $out/bin
    install -m755 protonhax $out/bin/protonhax
    install -m755 envload $out/bin/envload
  '';

  nativeBuildInputs = [
    tinycc
  ];
}
