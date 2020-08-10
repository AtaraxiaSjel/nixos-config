p: c:
with p;
let
  writeScript = name: script:
  writeTextFile {
    inherit name;
    text = callPackage script {
      iconfont = c.lib.base16.theme.iconFont;
      config = c;
    };
    executable = true;
    checkPhase =
      "${bash}/bin/bash -n $src || ${python3}/bin/python3 -m compileall $src";
  };
in
builtins.mapAttrs writeScript {
  weather = ./weather.nix;
  df = ./df.nix;
  vpn-status = ./vpn-status.nix;
}
