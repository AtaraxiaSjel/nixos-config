p: c:
with p;
builtins.mapAttrs (name: value:
writeTextFile {
  inherit name;
  text = callPackage value {
    iconfont = "Material Icons 11";
    config = c;
  };
  executable = true;
  checkPhase =
  "${bash}/bin/bash -n $src || ${python3}/bin/python3 -m compileall $src";
}) {
  battery = ./battery.nix;
  brightness = ./brightness.nix;
  email = ./email.nix;
  wireless = ./wireless.nix;
  weather = ./weather.nix;
  sound = ./sound.nix;
  music = ./music.nix;
  vpn-status = ./vpn-status.nix;
}
