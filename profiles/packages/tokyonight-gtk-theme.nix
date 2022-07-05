{ lib
, stdenv
, fetchFromGitHub
, gtk-engine-murrine
, jdupes
}:

stdenv.mkDerivation rec {
  pname = "tokyonight-gtk-theme";
  version = "unstable-2022-06-21";

  src = fetchFromGitHub {
    owner = "Fausto-Korpsvart";
    repo = "Tokyo-Night-GTK-Theme";
    rev = "39edc3409c39b2d1ed0b5dd9f8defe9a412acd43";
    sha256 = "sha256-CJ4kDi/Z2X4nihtiieP6b6YJWuGzr6LfOBipAXa8ZwI=";
  };

  nativeBuildInputs = [ jdupes ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes
    cp -a themes/Tokyonight* $out/share/themes

    # Replace duplicate files with hardlinks to the first file in each
    # set of duplicates, reducing the installed size
    jdupes -L -r $out/share

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
