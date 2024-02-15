{ pkgs, blockyUrl, prometheusUid, ... }:
let
  template =
    name: file: tmpl:
    (pkgs.runCommandLocal name { } ''
      mkdir $out
      cp ${pkgs.substituteAll ({ src = file; } // tmpl)} $out/${name}.json
    '');
in
pkgs.symlinkJoin {
  name = "grafana-dashboards";
  paths = [
    (template "grafana-blocky" ./blocky.json { inherit blockyUrl prometheusUid; })
  ];
}
