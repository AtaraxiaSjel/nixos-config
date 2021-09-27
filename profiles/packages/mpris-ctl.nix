{ stdenv, fetchFromGitHub, pkg-config, dbus, scdoc, installShellFiles }:

 stdenv.mkDerivation rec {
  pname = "mpris-ctl";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "mariusor";
    repo = "mpris-ctl";
    rev = "v${version}";
    sha256 = "1j3827yi89wdx3bw0wgwbhalg6r26rngf62g6g5baz2dksgrgagb";
  };

  nativeBuildInputs = [ pkg-config scdoc installShellFiles ];

  buildInputs = [ dbus ];

  buildPhase = ''
    make VERSION="0.8.4-2" release
  '';

  installPhase = ''
    scdoc < mpris-ctl.1.scd > mpris-ctl.1
    installManPage mpris-ctl.1
    install -D mpris-ctl $out/bin/mpris-ctl
  '';
}
