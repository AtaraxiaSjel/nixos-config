{ runCommand, fetchzip }:
let
  pname = "persistent_login";
  version = "5.3.0";
  src = fetchzip {
    url = "https://github.com/mfreiholz/persistent_login/archive/refs/tags/version-${version}.tar.gz";
    sha256 = "sha256-q1G3ZjyLmWYZ6lia93Ajbl72rHlrqP4uAEjx63XAx+E=";
  };
in runCommand "roundcube-plugin-${pname}-${version}" {
  inherit pname version src;
} ''
  mkdir -p $out/plugins/
  cp -r ${src} $out/plugins/${pname}
''