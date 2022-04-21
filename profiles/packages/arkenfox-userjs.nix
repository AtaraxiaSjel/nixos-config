{ stdenv, lib, arkenfox-repo }:
stdenv.mkDerivation {
  pname = "arknefox";
  version = "master";
  src = arkenfox-repo;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/user-js/profiles
    substituteInPlace prefsCleaner.sh \
      --replace 'currdir=$(pwd)' 'currdir=$@'
    cp {user.js,prefsCleaner.sh,updater.sh} $out/share/user-js/profiles
  '';

  meta = with lib; {
    description = "Firefox privacy, security and anti-fingerprinting";
    homepage = "https://github.com/arkenfox/user.js";
    maintainers = [ danielphan2003 ];
    platforms = platforms.all;
    license = licenses.mit;
  };
}