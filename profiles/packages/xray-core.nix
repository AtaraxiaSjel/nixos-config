{ lib, fetchFromGitHub, fetchurl, linkFarm, buildGoModule, runCommand, makeWrapper, nixosTests
, assetOverrides ? {}
}:

let
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "XTLS";
    repo = "Xray-core";
    rev = "v${version}";
    sha256 = "0g2bmy522lhip0rgb3hqyi3bidf4ljyjvvv3n1kb6lvm0p3br51b";
  };

  vendorSha256 = "sha256-QAF/05/5toP31a/l7mTIetFhXuAKsT69OI1K/gMXei0=";

  assets = {
    # MIT licensed
    "geoip.dat" = let
      geoipRev = "202210270100";
      geoipSha256 = "13qsgka98c8dwm1ykk59w76llv9lpbgqnhxrm3ndkdfkazacm85r";
    in fetchurl {
      url = "https://github.com/v2fly/geoip/releases/download/${geoipRev}/geoip.dat";
      sha256 = geoipSha256;
    };
  } // assetOverrides;

  assetsDrv = linkFarm "Xray-assets" (lib.mapAttrsToList (name: path: {
    inherit name path;
  }) assets);

  core = buildGoModule rec {
    pname = "Xray-core";
    inherit version src;

    inherit vendorSha256;

    doCheck = false;

    buildPhase = ''
      buildFlagsArray=(-v -p $NIX_BUILD_CORES -ldflags="-s -w")
      runHook preBuild
      go build "''${buildFlagsArray[@]}" -o xray ./main
      runHook postBuild
    '';

    installPhase = ''
      install -Dm755 xray -t $out/bin
    '';

    meta = {
      homepage = "https://github.com/XTLS/Xray-core";
      description = "Xray, Penetrates Everything. Also the best v2ray-core, with XTLS support. Fully compatible configuration.";
      license = with lib.licenses; [ mpl20 ];
      # maintainers = with lib.maintainers; [ servalcatty ];
    };
  };

in runCommand "Xray-${version}" {
  inherit src version;
  inherit (core) meta;

  nativeBuildInputs = [ makeWrapper ];

  passthru = {
    inherit core;
    # updateScript = ./update.sh;
    tests = {
      simple-vmess-proxy-test = nixosTests.Xray;
    };
  };

} ''
  for file in ${core}/bin/*; do
    makeWrapper "$file" "$out/bin/$(basename "$file")" \
      --set-default XRAY_LOCATION_ASSET ${assetsDrv}
  done
''
