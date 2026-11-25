{
  lib,
  fetchFromGitHub,
  doxygen,
  gtk3,
  libopenshot,
  wrapGAppsHook3,
  python3Packages,
  qt6,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "openshot-qt";
  version = "4.1.1";
  src = fetchFromGitHub {
    owner = "OpenShot";
    repo = "openshot-qt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-816DT37sorYcaUWW0/emqskYx/SVv4i0qImeml+8LW0=";
  };
  format = "setuptools";

  patches = [
    # https://github.com/OpenShot/openshot-qt/pull/6176
    ./recover-invalid-export-settings.patch
    # Store per-user data in $XDG_CONFIG_HOME/openshot_qt on Linux.
    ./xdg-config.patch
  ];

  outputs = [ "out" ]; # "lib" can't be split

  nativeBuildInputs = [
    doxygen
    wrapGAppsHook3
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    gtk3
    qt6.qtbase
    qt6.qtsvg
  ];

  propagatedBuildInputs = with python3Packages; [
    certifi
    charset-normalizer
    defusedxml
    httplib2
    idna
    packaging
    pyparsing
    pyside6
    pyzmq
    requests
    shiboken6
    sip
    urllib3
  ];

  doCheck = false;

  dontWrapGApps = true;
  dontWrapQtApps = true;

  # Pass GTK schemas and Qt plugins to the Python application wrapper.
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  postFixup =
    let
      pythonPath =
        lib.makeSearchPathOutput "lib" python3Packages.python.sitePackages
          finalAttrs.propagatedBuildInputs;
    in
    ''
      for f in $(find $out/bin/ -type f -executable); do
        wrapProgram "$f" \
          --prefix PYTHONPATH : "${pythonPath}:${libopenshot}/${python3Packages.python.sitePackages}:$out/${python3Packages.python.sitePackages}"
      done
    '';

  passthru = {
    inherit libopenshot;
    inherit (libopenshot) libopenshot-audio;
  };

  meta = {
    homepage = "http://openshot.org/";
    description = "Free, open-source video editor";
    longDescription = ''
      OpenShot Video Editor is a free, open-source video editor for Linux.
      OpenShot can take your videos, photos, and music files and help you create
      the film you have always dreamed of. Easily add sub-titles, transitions,
      and effects, and then export your film to DVD, YouTube, Vimeo, Xbox 360,
      and many other common formats.
    '';
    license = lib.licenses.gpl3Plus;
    mainProgram = "openshot-qt";
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
