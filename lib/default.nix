{ lib }:

{
  persist = rec {
    # Removes trailing slashes from path strings, preserving root "/"
    stripSlash =
      p: if lib.hasSuffix "/" p && p != "/" then lib.substring 0 ((lib.stringLength p) - 1) p else p;

    # Returns all parent ancestor paths between cacheDir and a nested statePath
    getAncestors =
      cacheDir: statePath:
      let
        prefix = if lib.hasSuffix "/" cacheDir then cacheDir else "${cacheDir}/";
      in
      if lib.hasPrefix prefix statePath then
        let
          rel = lib.removePrefix prefix statePath;
          parts = lib.splitString "/" rel;
          numParts = builtins.length parts;
          ancestorParts = map (i: lib.take i parts) (lib.range 1 (numParts - 1));
        in
        map (p: "${cacheDir}/${lib.concatStringsSep "/" p}") ancestorParts
      else
        [ ];

    # Filters out cache files that match state files or reside within state directories
    filterCacheFiles =
      cacheFiles: stateDirs: stateFiles:
      let
        absoluteStateDirs = map stripSlash stateDirs;
        absoluteStatePaths = absoluteStateDirs ++ (map stripSlash stateFiles);
      in
      lib.filter (
        f:
        let
          f' = stripSlash f;
          isState = lib.elem f' absoluteStatePaths;
          underStateDir = lib.any (
            s:
            let
              prefix = "${s}/";
            in
            lib.hasPrefix prefix f'
          ) absoluteStateDirs;
        in
        !(isState || underStateDir)
      ) cacheFiles;

    # Generates a safe find cleanup command for cache directories that prunes state subpaths
    # and retains parent directory structures.
    generateCacheDirCleanup =
      pkgs: cacheDirRaw: statePathsRaw:
      let
        strip = stripSlash;
        cacheDir = strip cacheDirRaw;
        statePaths = map strip statePathsRaw;

        isStateDir = lib.elem cacheDir statePaths;

        nestedStatePaths = lib.unique (
          lib.filter (
            s:
            let
              prefix = if lib.hasSuffix "/" cacheDir then cacheDir else "${cacheDir}/";
            in
            lib.hasPrefix prefix s
          ) statePaths
        );

        ancestorPaths = lib.unique (lib.concatMap (s: getAncestors cacheDir s) nestedStatePaths);

        pruneCond = lib.concatStringsSep " -o " (map (p: "-path ${lib.escapeShellArg p}") nestedStatePaths);

        ancCond = lib.concatStringsSep " -o " (map (p: "-path ${lib.escapeShellArg p}") ancestorPaths);
      in
      if isStateDir then
        "# Skipping ${cacheDir} as it is marked as state"
      else if nestedStatePaths == [ ] then
        "if [ -d ${lib.escapeShellArg cacheDir} ]; then ${pkgs.findutils}/bin/find ${lib.escapeShellArg cacheDir} -mindepth 1 -delete; fi"
      else if ancestorPaths == [ ] then
        "if [ -d ${lib.escapeShellArg cacheDir} ]; then ${pkgs.findutils}/bin/find ${lib.escapeShellArg cacheDir} -mindepth 1 \\( ${pruneCond} \\) -prune -o -exec ${pkgs.coreutils}/bin/rm -rf {} +; fi"
      else
        "if [ -d ${lib.escapeShellArg cacheDir} ]; then ${pkgs.findutils}/bin/find ${lib.escapeShellArg cacheDir} -mindepth 1 \\( ${pruneCond} \\) -prune -o \\( ${ancCond} \\) -a -true -o -exec ${pkgs.coreutils}/bin/rm -rf {} +; fi";
  };

  lists = rec {
    # getId: value -> comparable id (e.g. v: v.int for ports, v: v.uid for users)
    # attrs: attrset after apply
    # Returns list of duplicated ids.
    findDuplicates =
      getId: attrs:
      let
        all = lib.mapAttrsToList (_: v: getId v) attrs;
        uniq = lib.unique all;
      in
      lib.filter (p: builtins.length (builtins.filter (x: x == p) all) > 1) uniq;

    # Same as findDuplicates, but with owner names for error messages:
    # e.g. [ "8080 (used by a, b)" ]
    describeDuplicates =
      getId: attrs:
      map (
        dup:
        let
          owners = builtins.attrNames (lib.filterAttrs (_: v: getId v == dup) attrs);
        in
        "${toString dup} (used by ${lib.concatStringsSep ", " owners})"
      ) (findDuplicates getId attrs);

    # NixOS assertion that crashes the build on duplicates.
    # Usage:
    #   customLib.lists.mkNoDuplicatesAssertion {
    #     attrs = config.ataraxia.lists.ports;
    #     getId = v: v.int;
    #     label = "ataraxia.lists.ports";
    #   }
    mkNoDuplicatesAssertion =
      {
        attrs,
        getId,
        label,
      }:
      let
        all = lib.mapAttrsToList (_: v: getId v) attrs;
        details = describeDuplicates getId attrs;
      in
      {
        assertion = builtins.length all == builtins.length (lib.unique all);
        message = "Duplicate values detected in ${label}: ${lib.concatStringsSep ", " details}";
      };
  };
}
