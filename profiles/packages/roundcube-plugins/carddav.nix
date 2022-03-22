{ runCommand, fetchzip }:
let
  pname = "carddav";
  version = "4.3.0";
  src = fetchzip {
    url = "https://github.com/mstilkerich/rcmcarddav/releases/download/v${version}/carddav-v${version}.tar.gz";
    sha256 = "sha256-pc3ZPc4DnQDk+qUr0n/lWstjt9oIz+CocluXEjrkYco=";
  };
in runCommand "roundcube-plugin-${pname}-${version}" {
  inherit pname version src;
} ''
  mkdir -p $out/plugins/
  cp -r ${src} $out/plugins/${pname}
''