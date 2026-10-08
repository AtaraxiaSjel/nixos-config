{
  lib,
  curl,
  python3,
  python3Packages,
}:
python3Packages.buildPythonApplication {
  pname = "remna-overlay";
  version = "1.0";

  pyproject = false;

  src = ./server.py;

  dontUnpack = true;

  dependencies = [ ];

  nativeCheckInputs = [ curl ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/remna-overlay"
    runHook postInstall
  '';

  # Smoke test. The health endpoint touches no panel, so it is sandbox-safe.
  installCheckPhase = ''
    runHook preCheck
    ${lib.getExe python3} -m py_compile "$src"
    PORT=18091 ${lib.getExe python3} "$src" &
    serverPid=$!
    trap "kill $serverPid" EXIT
    for _ in $(seq 1 50); do
      curl -fsS http://127.0.0.1:18091/ext/health 2>/dev/null | grep -q '^ok$' && break
      sleep 0.2
    done
    curl -fsS http://127.0.0.1:18091/ext/health | grep -q '^ok$'
    kill "$serverPid"
    trap - EXIT
    runHook postCheck
  '';

  meta = {
    description = "Serve extended sing-box JSON over HTTP with squad overlay for Remnawave";
    homepage = "https://github.com/AtaraxiaSjel/nixos-config";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.ataraxiasjel ];
    mainProgram = "remna-overlay";
    platforms = lib.platforms.linux;
  };
}
