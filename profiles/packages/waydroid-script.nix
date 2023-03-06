{ stdenv
, lib
, fetchFromGitHub
, python3
, lzip
, sqlite
, util-linux
, makeBinaryWrapper
}: let
  py = python3.withPackages (pythonPackages: with pythonPackages; [
    tqdm
    requests
    dbus-python
  ]);
in stdenv.mkDerivation {
  name = "waydroid-script";
  version = "master";

  src = fetchFromGitHub {
    repo = "waydroid_script";
    owner = "casualsnek";
    rev = "2f4f056fb143e393756952ea74fe4b6c85a35cc1";
    hash = "sha256-dYR22NtqHZ7Px4Q+oVEUw0Ke5+hOJSgwLEuTmpkM9T8=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r {stuffs,tools} $out/bin
    cp main.py $out/bin/waydroid-script
    chmod +x $out/bin/waydroid-script
    sed -i '1i #!${py}/bin/python' $out/bin/waydroid-script
    wrapProgram $out/bin/waydroid-script --prefix PATH : ${lib.makeBinPath [ lzip sqlite util-linux ]}
  '';
}