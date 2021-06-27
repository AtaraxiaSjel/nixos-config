{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "bibata-cursors";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v${version}/Bibata.tar.gz";
    sha256 = "sha256-AcX30YL4HSqzlmTiC0MIStNWuWllkQqjNbkRTQkpu18=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p "$out/share/icons"
    tar -xf $src --directory "$out/share/icons/"
  '';

  meta = with lib; {
    description = "Material Based Cursor";
    homepage = "https://github.com/ful1e5/Bibata_Cursor";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
