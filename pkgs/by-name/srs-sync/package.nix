{
  lib,
  python3,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "srs-sync";
  version = "0.1.0";

  pyproject = false;

  src = ./sync-srs.py;

  dontUnpack = true;

  dependencies = with python3Packages; [ boto3 ];

  # Runtime sys.path for the wrapper hook (patchPythonScript injection).
  # `dependencies` alone only covers build time; without this, the installed
  # script cannot `import boto3` when S3_BUCKET is set.
  pythonPath = with python3Packages; [ boto3 ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/srs-sync"
    runHook postInstall
  '';

  # Smoke test. --help exits before any env/network access, so it is sandbox-safe.
  installCheckPhase = ''
    runHook preCheck
    ${lib.getExe python3} -m py_compile "$src"
    ${lib.getExe python3} "$src" --help > /dev/null
    runHook postCheck
  '';

  meta = {
    description = "Mirror sing-box .srs rule-sets from upstream to own hosting";
    homepage = "https://github.com/AtaraxiaSjel/nixos-config";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.ataraxiasjel ];
    mainProgram = "srs-sync";
    platforms = lib.platforms.linux;
  };
}
