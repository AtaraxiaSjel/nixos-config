{ lib, python3, fetchFromGitHub, writeText, libnotify, gobject-introspection, wrapGAppsHook }:
let
  version = "1.1.4";
  setup-py = writeText "setup.py" ''
    from distutils.core import setup
    setup(
        name='a2ln',
        version='${version}',
        scripts=['a2ln'],
    )
  '';
in python3.pkgs.buildPythonApplication rec {
  inherit version;
  pname = "a2ln";

  src = fetchFromGitHub {
    repo = "a2ln-server";
    owner = "patri9ck";
    rev = version;
    sha256 = "1lh8wbrhcdaqy1dhg13ay7s4hip7g911fbb5h0v3a99kzgn6vl1m";
  };

  preBuild = ''
    cp ${setup-py} setup.py
  '';

  propagatedBuildInputs = with python3.pkgs; [
    pillow pygobject3 setproctitle pyzmq qrcode
    wrapGAppsHook libnotify gobject-introspection
  ];

  strictDeps = false;

  meta = with lib; {
    description = "A way to display Android phone notifications on Linux (Server)";
    license = licenses.gpl3;
  };
}