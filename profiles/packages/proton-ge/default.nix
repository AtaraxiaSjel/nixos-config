{ stdenv
, lib
, fetchurl
, writeScript
,
}:
stdenv.mkDerivation rec {
  name = "proton-ge-custom";
  version = "GE-Proton7-53";

  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    sha256 = "sha256-J3e/WM/Cms8uqCOcjIQjFQZJL++rrIenhnpLsCbwwXA=";
  };

  passthru.runUpdate = true;
  # passthru.updateScript = ./update.sh;

  buildCommand = ''
    mkdir -p $out/bin
    tar -C $out/bin --strip=1 -x -f $src
  '';

  meta = with lib; {
    description = "Compatibility tool for Steam Play based on Wine and additional components";
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
