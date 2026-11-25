{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "d3stick";
  version = "0.1.0";

  pyproject = false;

  src = ./d3stick.py;

  dontUnpack = true;

  dependencies = with python3Packages; [ evdev ];

  pythonPath = with python3Packages; [ evdev ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/d3stick"
    runHook postInstall
  '';

  meta = {
    description = "Gamepad emulator for Diablo 3 on switch emulator";
    homepage = "https://github.com/AtaraxiaSjel/nixos-config";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.ataraxiasjel ];
    mainProgram = "d3stick";
    platforms = lib.platforms.linux;
  };
}
