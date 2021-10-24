{ stdenv, fetchFromGitHub }:

 stdenv.mkDerivation rec {
  pname = "reshade-shaders";
  version = "4497a45";

  src = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade-shaders";
    rev = "a2314cbf9a6c96de4d434b2f9ab8fa9265b8e575";
    sha256 = "07lvybc8x1633ynsq0z23hkq6jg97k339sh6fd0d8kk8n123z1xw";
  };

  buildPhase = "";

  installPhase = ''
    install -dm 755 $out/share/reshade/shaders
    install -Dm 644 Shaders/*.*  $out/share/reshade/shaders/
    install -dm 755 $out/share/reshade/textures
    install -Dm 644 Textures/*.* $out/share/reshade/textures/
  '';
}
