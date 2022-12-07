{ stdenv, lib, arkenfox-repo }:
stdenv.mkDerivation {
  pname = "arkenfox-userjs";
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
    maintainers = [ ];
    platforms = platforms.all;
    license = licenses.mit;
  };
}