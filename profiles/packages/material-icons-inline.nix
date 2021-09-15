{ stdenv, fetchurl, pkgs }:
let
  icons = "https://gist.github.com/AlukardBF/e92009045bbfc6f7a84e082c6634b18f/raw/3e6e12c213fba1ec28aaa26430c3606874754c30/MaterialIcons-Regular-for-inline.ttf";
in stdenv.mkDerivation {
  name = "material-icons-inline";

  src = fetchurl {
    name = "material-icons-inline";
    url = icons;
    sha256 = "sha256-huy/En0YX6bkJmrDazxPltsWZOUPxGuQs12r6L+h+oA=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype/MaterialIcons-Regular-for-inline.ttf
  '';

  meta = with pkgs.lib; {
    description = "Material Icons Font patched for inline";
  };
}
