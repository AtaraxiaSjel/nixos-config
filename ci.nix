with builtins;
let
  outputs = builtins.getFlake (toString ./.);
  pkgs = outputs.inputs.nixpkgs;

  isHost = n: pkgs.lib.strings.hasPrefix "host" n;
  isDerivation = p: isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: !(p.meta.broken or false);
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p:
    isAttrs p && p.recurseForDerivations or false;

  nameValuePair = n: v: {
    name = n;
    value = v;
  };

  concatMap = builtins.concatMap or (f: xs: concatLists (map f xs));

  flattenPkgs = s:
    let
      f = p:
        if shouldRecurseForDerivations p then
          flattenPkgs p
        else if isDerivation p then
          [ p ]
        else
          [ ];
    in concatMap f (attrValues s);

  outputsOf = p: map (o: p.${o}) p.outputs;
  hostAttrs = outputs.packages.x86_64-linux;

  hostPkgs = flattenPkgs (listToAttrs (map (n: nameValuePair n hostAttrs.${n})
    (filter (n: isHost n) (attrNames hostAttrs))));
in rec {
  buildPkgs = filter isBuildable hostPkgs;
  cachePkgs = filter isCacheable buildPkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}
