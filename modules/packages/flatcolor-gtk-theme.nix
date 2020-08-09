{ stdenv, fetchFromGitHub, gtk-engine-murrine }:

stdenv.mkDerivation rec {
  name = "flatcolor-gtk-theme";

  src = fetchFromGitHub {
    owner = "deviantfero";
    repo = "wpgtk-templates";
    rev = "90da48ecb26a0b36423db7fb8076615b43b72b47";
    sha256 = "1k7navk73mzw9lgvgikj96mqdkfb2icw60mdc59dq51rd0nk6d2b";
  };

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase = ''
    mkdir -p $out/share/themes
    cp -r FlatColor $out/share/themes
    rm $out/share/themes/FlatColor/LICENSE
  '';
}