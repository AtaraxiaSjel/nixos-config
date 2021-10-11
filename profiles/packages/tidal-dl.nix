{ python39Packages, fetchurl }:
with python39Packages; let
  aigpy = buildPythonPackage rec {
    pname = "aigpy";
    version = "2021.9.10.3";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/77/4d/e39028ff5c4428c332b2ff5c6c660834134f15181296132c5604116a43c6/aigpy-2021.9.10.3-py3-none-any.whl";
      sha256 = "sha256-XRXwLyV5WVOTU1JQ0vEbI6CJ0VfA2S6X5WESvlRV8sk=";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      colorama
      mutagen
      requests
    ];
  };
  lyricsgenius = buildPythonPackage rec {
    pname = "lyricsgenius";
    version = "3.0.1";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/0d/32/be32f6922f70fd1b9900b50b228f6585cd60a96bdf03589df738f627d388/lyricsgenius-3.0.1-py3-none-any.whl";
      sha256 = "01cv77wf682b48wr71cgp0djafxl1j6d17nsyrzvwvkbkvbzfp8l";
    };
    format = "wheel";
    doCheck = false;
    buildInputs = [];
    checkInputs = [];
    nativeBuildInputs = [];
    propagatedBuildInputs = [
      beautifulsoup4
      requests
    ];
  };
in buildPythonPackage rec {
  pname = "tidal-dl";
  version = "2021.9.23.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-eMVfc+bdj2Hr6gMCbcXoEVbmSQkyyK1PSxKNgD2++Vw=";
  };

  preBuild = ''
    export HOME=$TMPDIR
  '';

  propagatedBuildInputs = [
    beautifulsoup4
    certifi
    chardet
    colorama
    idna
    mutagen
    prettytable
    psutil
    pycryptodome
    pydub
    requests
    soupsieve
    urllib3
    aigpy
    lyricsgenius
  ];
}