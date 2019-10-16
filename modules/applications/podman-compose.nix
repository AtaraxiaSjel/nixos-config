{ lib, python37Packages }:
with python37Packages;
buildPythonPackage rec {
  pname = "podman-compose";
  version = "0.1.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1sgbc889zq127qhxa9frhswa1mid19fs5qnyzfihx648y5i968pv";
  };

  propagatedBuildInputs = [ pyaml ];

  meta = with lib; {
    homepage = https://github.com/containers/podman-compose;
    description = "A script to run docker-compose.yml using podman";
    license = licenses.gpl2;
    # maintainers = with maintainers; [ alukardbf ];
  };
}