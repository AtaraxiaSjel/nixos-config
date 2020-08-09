{ stdenv, fetchFromGitHub, rustPlatform, cmake, pkgconfig }:

with rustPlatform;

buildRustPackage rec {
  pname = "nomino";
  version = "0.4.2";

  cargoSha256 = "sha256-9p/HD16yreWdjbCaUaan07fnVpPwOCiHaVemfXP6L8c=";

  src = fetchFromGitHub {
    owner = "yaa110";
    repo = "nomino";
    rev = "8f437051ea51d333aa685679f0e5902d6709d7ef";
    sha256 = "1qmy73gmmf0i9svzrw2jz7nlypfybyd1izwd1a13fgm9dn7amja3";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  meta = with stdenv.lib; {
    description = "Batch rename utility for developers";
    homepage = "https://github.com/yaa110/nomino";
    license = licenses.mit;
    maintainers = with maintainers; [ alukardbf ];
  };
}