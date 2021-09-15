{ stdenv, lib, fetchurl }:
stdenv.mkDerivation rec {
  pname = "nomino";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/yaa110/nomino/releases/download/${version}/nomino-linux-64bit";
    sha256 = "sha256-yVpCIfkWR6HyQusNTtl5QcJ4EsQMsaRE1IpwC+MoVhk=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/nomino
  '';

  meta = with lib; {
    description = "Batch rename utility for developers";
    homepage = "https://github.com/yaa110/nomino";
    license = licenses.mit;
    maintainers = with maintainers; [ alukardbf ];
  };
}
