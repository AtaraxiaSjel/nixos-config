{ stdenv, fetchFromGitHub, python3Packages }:
stdenv.mkDerivation rec {
  name = "bpytop";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "aristocratos";
    repo = "${name}";
    rev = "v${version}";
    sha256 = "08hi55wh423j1rfdivnil94sg9admxygzv1diibfygwvknilv9qj";
  };

  propagatedBuildInputs = with python3Packages; [ psutil ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp -p bpytop.py "$out/bin/bpytop"
    mkdir -p "$out/share/bpytop/doc"
    cp -p README.md "$out/share/bpytop/doc"
    cp -pr themes "$out/share/bpytop"
    chmod 755 "$out/bin/bpytop"
  '';

  meta = {
    homepage = "https://github.com/aristocratos/bpytop";
    description = "Resource monitor that shows usage and stats for processor, memory, disks, network and processes.";
    license = stdenv.lib.licenses.asl20;
    maintainers = with stdenv.lib.maintainers; [ alukardbf ];
  };
}