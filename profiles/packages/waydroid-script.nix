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
    rev = "6c78b793c8405874b4be5b46527f81bca3f14c08";
    hash = "sha256-Wkbm3/PihXCrGCMrRTfBM/OA1gXwafXlW5m7fvkOPOU=";
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