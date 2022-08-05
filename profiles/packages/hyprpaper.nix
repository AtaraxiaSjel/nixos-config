{
  lib,
  stdenv,
  pkg-config,
  cmake,
  ninja,
  cairo,
  fribidi,
  libdatrie,
  libjpeg,
  libselinux,
  libsepol,
  libthai,
  pango,
  pcre,
  utillinux,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlr-protocols,
  libXdmcp,
  version ? "git",
  src,
}:
stdenv.mkDerivation {
  pname = "hyprpaper";
  inherit version;
  src = src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    cairo
    fribidi
    libdatrie
    libjpeg
    libselinux
    libsepol
    libthai
    pango
    pcre
    wayland
    wayland-protocols
    wayland-scanner
    wlr-protocols
    libXdmcp
    utillinux
  ];

  configurePhase = ''
    runHook preConfigure

    make release

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/licenses}

    install -Dm755 build/hyprpaper -t $out/bin
    install -Dm644 LICENSE -t $out/share/licenses/hyprpaper

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/hyprwm/hyprpaper";
    description = "A blazing fast wayland wallpaper utility with IPC controls";
    license = licenses.bsd3;
    platforms = platforms.linux;
    mainProgram = "hyprpaper";
  };
}
