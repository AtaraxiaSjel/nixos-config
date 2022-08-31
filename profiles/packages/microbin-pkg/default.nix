{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "microbin";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "szabodanika";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ppm34sj01pwwfyyy433k7r6li9ckngjq6j9xjjb2k184hzy2dva";
  };

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  cargoSha256 = "sha256-AkFrS26uwJgHXwXWnSU4FRwWA7c3iZmpZ35QiKKk18s=";

  meta = with lib; {
    description = "A tiny, self-contained, configurable paste bin and URL shortener written in Rust.";
    homepage = "https://github.com/szabodanika/microbin";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}