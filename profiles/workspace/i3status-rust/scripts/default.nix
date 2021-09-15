p: c:
with p;
let
  writeScript = name: script:
  writeTextFile {
    inherit name;
    text = callPackage script {
      iconfont = c.lib.base16.theme.fonts.icon.family;
      config = c;
    };
    executable = true;
    checkPhase =
      "${bash}/bin/bash -n $src || ${python3}/bin/python3 -m compileall $src";
  };
in
builtins.mapAttrs writeScript {
  cputemp = ./cputemp.nix;
  weather = ./weather.nix;
  df = ./df.nix;
  vpn-status = ./vpn-status.nix;
}
