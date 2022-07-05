{ lib, stdenv, fetchurl, repo ? null }:

stdenv.mkDerivation rec {
  pname = "bibata-cursors-tokyonight";
  version = "1.0";

  src = repo;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p "$out/share/icons"
    cp -r * $out/share/icons
  '';

  meta = with lib; {
    description = "Material Based Cursor";
    homepage = "https://code.ataraxiadev.com/AtaraxiaDev/Bibata-Modern-TokyoNight";
    license = licenses.unlicense;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
