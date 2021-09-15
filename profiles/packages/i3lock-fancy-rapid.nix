{ stdenv, fetchFromGitHub, i3lock, xorg, inputs, pkgs }:
stdenv.mkDerivation rec {
  name = "i3lock-fancy-rapid";
  src = inputs.i3lock-fancy-rapid;
  # src = fetchFromGitHub {
  #   owner = "yvbbrjdr";
  #   repo = "i3lock-fancy-rapid";
  #   rev = "c67f09bc8a48798c7c820d7d4749240b10865ce0";
  #   sha256 = "0jhvlj6v6wx70239pgkjxd42z1s2bzfg886ra6n1rzsdclf4rkc6";
  # };
  buildInputs = [ i3lock xorg.libX11 ];

  installPhase = ''
    mkdir -p $out/bin
    cp i3lock-fancy-rapid $out/bin/i3lock-fancy-rapid
  '';

  meta = with pkgs.lib; {
    description = "A faster implementation of i3lock-fancy. It is blazing fast and provides a fully configurable box blur. It uses linear-time box blur and accelerates using OpenMP.";
    homepage = https://github.com/yvbbrjdr/i3lock-fancy-rapid;
    maintainers = with maintainers; [ ];
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}