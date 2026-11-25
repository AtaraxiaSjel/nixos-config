{
  lib,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "prefix-cleaner";
  version = "1.0";

  pyproject = false;

  src = ./prefix-cleaner.py;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/prefix-cleaner"
    runHook postInstall
  '';

  meta = {
    description = "Steam prefix cleaner";
    homepage = "https://github.com/AtaraxiaSjel/nixos-config";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.ataraxiasjel ];
    mainProgram = "prefix-cleaner";
    platforms = lib.platforms.linux;
  };
}
