{ stdenv, fetchFromGitHub, coreutils, i3lock-color, getopt, fontconfig, ffmpeg_4, xorg }:

stdenv.mkDerivation rec {
  rev = "c8f648c5e35178dd39ecc83094bf921752b7878b";
  name = "i3lock-fancy-ffmpeg_rev${builtins.substring 0 7 rev}";
  src = fetchFromGitHub {
    owner = "rinfiyks";
    repo = "i3lock-fancy";
    inherit rev;
    sha256 = "1pdvzi5d9p2r5md2g289j95333nkpb3ah3si91c5f6350swd8jmz";
  };
  buildInputs = [ i3lock-color xorg.xrandr ffmpeg_4 coreutils getopt fontconfig ];
  patchPhase = ''
    sed -i -e "s|(mktemp)|(${coreutils}/bin/mktemp)|" i3lock-fancy
    sed -i -e "s|(xrandr)|(${xorg.xrandr}/bin/xrandr)|" i3lock-fancy
    sed -i -e "s|'rm -f |'${coreutils}/bin/rm -f |" i3lock-fancy
    sed -i -e "s|i3lock -i |${i3lock-color}/bin/i3lock-color -i |" i3lock-fancy
    sed -i -e 's|lock_file="/usr/share/i3lock-fancy/lock.png"|lock_file="'$out'/share/i3lock-fancy/icons/lock.png"|' i3lock-fancy
    sed -i -e "s|getopt |${getopt}/bin/getopt |" i3lock-fancy
    sed -i -e "s|fc-match |${fontconfig.bin}/bin/fc-match |" i3lock-fancy
    sed -i -e "s|fc-list |${fontconfig.bin}/bin/fc-list |" i3lock-fancy
    sed -i -e "s|ffmpeg -f |${ffmpeg_4}/bin/ffmpeg -f |" i3lock-fancy
    rm Makefile
  '';
  installPhase = ''
    mkdir -p $out/bin $out/share/i3lock-fancy/icons
    cp i3lock-fancy $out/bin/i3lock-fancy
    cp icons/lock*.png $out/share/i3lock-fancy/icons
  '';
  meta = with stdenv.lib; {
    description = "i3lock is a bash script that takes a screenshot of the desktop, blurs the background and adds a lock icon and text.";
    homepage = https://github.com/meskarune/i3lock-fancy;
    maintainers = with maintainers; [ ];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
