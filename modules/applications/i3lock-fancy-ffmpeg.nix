{ stdenv, fetchFromGitHub, coreutils, scrot, ffmpeg, gawk
, i3lock-color, getopt, fontconfig
}:

stdenv.mkDerivation rec {
  rev = "c8f648c5e35178dd39ecc83094bf921752b7878b";
  name = "i3lock-fancy-ffmpeg_rev${builtins.substring 0 7 rev}";
  src = fetchFromGitHub {
    owner = "rinfiyks";
    repo = "i3lock-fancy";
    inherit rev;
    sha256 = "1pdvzi5d9p2r5md2g289j95333nkpb3ah3si91c5f6350swd8jmz";
  };
  patchPhase = ''
    rm Makefile
  '';
  installPhase = ''
    mkdir -p $out/bin $out/share/i3lock-fancy-ffmpeg/icons
    cp i3lock-fancy $out/bin/i3lock-fancy-ffmpeg
    cp icons/lock*.png $out/share/i3lock-fancy-ffmpeg/icons
  '';
  meta = with stdenv.lib; {
    description = "i3lock is a bash script that takes a screenshot of the desktop, blurs the background and adds a lock icon and text.";
    homepage = https://github.com/meskarune/i3lock-fancy;
    maintainers = with maintainers; [ ];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
