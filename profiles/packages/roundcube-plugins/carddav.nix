{ runCommand, fetchzip }:
let
  pname = "carddav";
  version = "5.0.1";
  src = fetchzip {
    url = "https://github.com/mstilkerich/rcmcarddav/releases/download/v${version}/carddav-v${version}.tar.gz";
    sha256 = "sha256-qB4cif4lK9IejOqPexp5RmcGrNGcB1h6cxcGFYhZvRA=";
  };
in runCommand "roundcube-plugin-${pname}-${version}" {
  inherit pname version src;
} ''
  mkdir -p $out/plugins/
  cp -r ${src} $out/plugins/${pname}
''