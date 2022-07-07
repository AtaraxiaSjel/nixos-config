{ lib, stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "bibata-cursors-tokyonight";
  version = "1.0";

  src = fetchgit {
    url = "https://code.ataraxiadev.com/AtaraxiaDev/Bibata-Modern-TokyoNight.git";
    sha256 = "sha256-PREfEgv+FQZjYAQijY3bHQ/0E/L8HgJUBWeA0vdBkAA=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p "$out/share/icons"
    cp -r $src/Bibata-Modern-TokyoNight $out/share/icons
  '';

  meta = with lib; {
    description = "Material Based Cursor";
    homepage = "https://code.ataraxiadev.com/AtaraxiaDev/Bibata-Modern-TokyoNight";
    license = licenses.unlicense;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
