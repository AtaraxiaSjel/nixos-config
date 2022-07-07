{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "tokyonight-icon-theme";
  version = "unstable-2022-06-21";

  src = fetchFromGitHub {
    owner = "Fausto-Korpsvart";
    repo = "Tokyo-Night-GTK-Theme";
    rev = "39edc3409c39b2d1ed0b5dd9f8defe9a412acd43";
    sha256 = "sha256-CJ4kDi/Z2X4nihtiieP6b6YJWuGzr6LfOBipAXa8ZwI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -a icons/* $out/share/icons

    runHook postInstall
  '';

  meta = with lib; {
    description = "A GTK theme based on the Tokyo Night colour palette";
    homepage = "https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
