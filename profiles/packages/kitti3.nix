{ lib, buildPythonPackage, fetchPypi, i3ipc }:

buildPythonPackage rec {
  pname = "kitti3";
  version = "0.4.1";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    # format = "wheel";
    dist = "py3";
    python = "py3";
    sha256 = "0sf9h0cfs24hgln25z2j4jib530mq931h8xjgxkfr79qrqr3k6dm";
  };

  doCheck = false;

  propagatedBuildInputs = [ i3ipc ];

  meta = with lib; {
    homepage = "https://github.com/LandingEllipse/kitti3";
    description = "Kitty drop-down service for sway & i3wm";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ataraxiadev ];
  };
}