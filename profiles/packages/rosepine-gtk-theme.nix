{ lib
, stdenv
, fetchFromGitHub
, gtk-engine-murrine
, jdupes
}:

stdenv.mkDerivation rec {
  pname = "rosepine-gtk-theme";
  version = "unstable-2022-09-03";

  src = fetchFromGitHub {
    owner = "Fausto-Korpsvart";
    repo = "Rose-Pine-GTK-Theme";
    rev = "1ffc697c6bed594c262647b0ec01e5f3de5a5e77";
    sha256 = "1psdrf3hfq8h7lhz75j4780r5p9l6cjmsrpfwhk4yyi4hbyk1n9c";
  };

  nativeBuildInputs = [ jdupes ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes
    cp -a themes/Rosepine* $out/share/themes

    # Replace duplicate files with hardlinks to the first file in each
    # set of duplicates, reducing the installed size
    jdupes -L -r $out/share

    runHook postInstall
  '';

  meta = with lib; {
    description = "A GTK theme with the Rosé Pine colour palette";
    homepage = "https://github.com/Fausto-Korpsvart/Rose-Pine-GTK-Theme";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
