{ lib, fetchFromGitHub, fetchurl, linkFarm, buildGoModule, runCommand, makeWrapper, nixosTests
, assetOverrides ? {}
}:

let
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "XTLS";
    repo = "Xray-core";
    rev = "v${version}";
    sha256 = "068i2sdykmr7xznsvq5d80ivzkmmnd8gy3v90n8g8h7aqkgx25w6";
  };

  vendorSha256 = "sha256-ZFbYUybbKKqmFz7mi7QpgaRj0i7is4iM/aBbPAqCuSM=";

  assets = {
    # MIT licensed
    "geoip.dat" = let
      geoipRev = "202203170039";
      geoipSha256 = "1j76akll181xnrgrs032sri3m7azjmzql27bjsyycln0zgg87h8j";
    in fetchurl {
      url = "https://github.com/v2fly/geoip/releases/download/${geoipRev}/geoip.dat";
      sha256 = geoipSha256;
    };

    # MIT licensed
    "geosite.dat" = let
      geositeRev = "20220320175821";
      geositeSha256 = "11j7j4hmzfr2l3zwa2xlinjdqmsfjg4952qzkw1qwrafifrarzvf";
    in fetchurl {
      url = "https://github.com/v2fly/domain-list-community/releases/download/${geositeRev}/dlc.dat";
      sha256 = geositeSha256;
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
