{ stdenv, lib, fetchFromGitHub, python3, lzip, sqlite, util-linux, makeBinaryWrapper }:
let
  py = python3.withPackages (pythonPackages: with pythonPackages; [
    tqdm
    requests
  ]);
in stdenv.mkDerivation {
  name = "myscript";
  version = "git";

  src = fetchFromGitHub {
    repo = "waydroid_script";
    owner = "AlukardBF";
    rev = "d8eaf667220c5ef72519280354d373a149e041a3";
    sha256 = "1m15x87c7pc7ag624zccjjb19ixki01c0pfr78myc8nbavi56lfz";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp waydroid_extras.py $out/bin/waydroid-script
    chmod +x $out/bin/waydroid-script
    sed -i '1i #!${py}/bin/python' $out/bin/waydroid-script
    wrapProgram $out/bin/waydroid-script --prefix PATH : ${lib.makeBinPath [ lzip sqlite util-linux ]}
  '';
}