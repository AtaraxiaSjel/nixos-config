{ python3Packages, python2, fetchFromGitHub, fetchzip }:
let
  fontpatcher = python3Packages.buildPythonApplication rec {
    name = "fontpatcher";
    src = fetchFromGitHub {
      owner = "powerline";
      repo = "fontpatcher";
      rev = "c3488091611757cb02014ed7ed2f11be0208da83";
      sha256 = "1261h8233spflbbwbjz9w9bxcmznjldxwff08xn2cly6r9f49a0s";
    };
    propagatedBuildInputs = [
      python2
      python3Packages.fontforge
    ];
    doCheck = false;
    preFixup = ''
      mkdir -p $out/fonts
      cp fonts/* $out/fonts
    '';
  };

  version = "5.1.0";
in fetchzip {
  name = "ibm-plex-powerline-${version}";

  url = "https://github.com/IBM/plex/releases/download/v${version}/OpenType.zip";

  postFetch = ''
    mkdir -p $out/share/fonts/opentype
    unzip -j $downloadedFile "OpenType/*/IBMPlexMono*.otf" -d $out/share/fonts/opentype
    cd $out/share/fonts/opentype
    ${fontpatcher}/bin/powerline-fontpatcher $out/share/fonts/opentype/*
    rm -f $out/share/fonts/opentype/IBMPlex*
  '';

  sha256 = "sha256-DaNXraX1gXhoS3Pnttw4VVHRvGrQRR2wuplNJn+c6cg=";
}

