{ multimc-repo, lib, pkgs, mkDerivation }:

let
  libpath = with pkgs; lib.makeLibraryPath [ xorg.libX11 xorg.libXext xorg.libXcursor xorg.libXrandr xorg.libXxf86vm libpulseaudio libGL ];
in mkDerivation rec {
  pname = "multimc";
  version = "unstable";
  src = multimc-repo;
  nativeBuildInputs = with pkgs; [ cmake file makeWrapper ];
  buildInputs = with pkgs; [ libsForQt5.qt5.qtbase jdk8 jdk zlib ];

  # patches = [ ./0001-pick-latest-java-first.patch ];

  postPatch = ''
    # hardcode jdk paths
    substituteInPlace api/logic/java/JavaUtils.cpp \
      --replace 'scanJavaDir("/usr/lib/jvm")' 'javas.append("${pkgs.jdk}/lib/openjdk/bin/java")' \
      --replace 'scanJavaDir("/usr/lib32/jvm")' 'javas.append("${pkgs.jdk8}/lib/openjdk/bin/java")'
  '';

  cmakeFlags = [ "-DMultiMC_LAYOUT=lin-system" ];

  postInstall = ''
    ls -lah ./
    ls -lah ../
    install -Dm644 ../application/resources/multimc/scalable/multimc.svg $out/share/pixmaps/multimc.svg
    install -Dm755 ../application/package/linux/multimc.desktop $out/share/applications/multimc.desktop

    # xorg.xrandr needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
    wrapProgram $out/bin/multimc \
      --set GAME_LIBRARY_PATH /run/opengl-driver/lib:${libpath} \
      --prefix PATH : ${lib.makeBinPath [ pkgs.xorg.xrandr ]}
  '';

  meta = with lib; {
    homepage = "https://multimc.org/";
    description = "A free, open source launcher for Minecraft";
    longDescription = ''
      Allows you to have multiple, separate instances of Minecraft (each with their own mods, texture packs, saves, etc) and helps you manage them and their associated options with a simple interface.
    '';
    platforms = platforms.linux;
    license = licenses.asl20;
    # upstream don't want us to re-distribute this application:
    # https://github.com/NixOS/nixpkgs/issues/131983
    hydraPlatforms = [];
    maintainers = with maintainers; [ cleverca22 starcraft66 ];
  };
}