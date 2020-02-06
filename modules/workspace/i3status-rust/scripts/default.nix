p: c:
with p;
builtins.mapAttrs (name: value:
writeTextFile {
  inherit name;
  text = callPackage value {
    iconfont = "FontAwesome 11";
    config = c;
  };
  executable = true;
  checkPhase =
  "${bash}/bin/bash -n $src";
}) {
  weather = ./weather.nix;
  df = ./df.nix;
  vpn-status = ./vpn-status.nix;
}
