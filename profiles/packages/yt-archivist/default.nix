
{ lib, stdenvNoCC, fetchFromGitHub, makeWrapper, perl, yt-dlp, ffmpeg, coreutils }:
stdenvNoCC.mkDerivation rec {
  name = "yt-archivist";
  version = "3.4.0";
  src = fetchFromGitHub {
    owner = "TheFrenchGhosty";
    repo = "TheFrenchGhostys-Ultimate-YouTube-DL-Scripts-Collection";
    rev = version;
    hash = "sha256-nteenn+XLCyp1WPaCUth2zAh0nhawYLEQEKD+L93nJM=";
  };
  patches = [ ./fix.patch ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp "scripts/Archivist Scripts/Archivist Scripts (No Comments)/Channels/Channels.sh" $out/bin/yt-archivist
    cp "scripts/Archivist Scripts/Recent Scripts/Channels/Channels.sh" $out/bin/yt-archivist-recent
  '';
  postFixup = ''
    for f in $out/bin/*; do
      wrapProgram $f \
        --set PATH ${lib.makeBinPath [ perl yt-dlp ffmpeg coreutils ]}
    done
  '';
  meta = with lib; {
    description = "The ultimate collection of scripts for YouTube-DL";
    homepage = "https://github.com/TheFrenchGhosty/TheFrenchGhostys-Ultimate-YouTube-DL-Scripts-Collection";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}