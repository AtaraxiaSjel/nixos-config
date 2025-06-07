inputs: final: prev:
let
  inherit (prev.hostPlatform) system;
  unstable = import inputs.nixpkgs-unstable {
    config = {
      allowUnfree = true;
    };
    localSystem = { inherit system; };
  };
in
{
  # attic-client = inputs.attic.packages.${system}.attic;
  # attic-server = inputs.attic.packages.${system}.attic-server;
  # cassowary-py = inputs.cassowary.packages.${system}.cassowary;
  hyprlandUnstable = unstable.hyprland;
  hyprlandPortalUnstable = unstable.xdg-desktop-portal-hyprland;
  intel-vaapi-driver = prev.intel-vaapi-driver.override { enableHybridCodec = true; };
  mesaUnstable = unstable.mesa;
  mesaUnstablei686 = unstable.driversi686Linux.mesa;
  # nix-alien = inputs.nix-alien.packages.${system}.nix-alien;
  # nix-direnv = inputs.nix-direnv.packages.${system}.default.override { nix = final.nix; };
  # nix-fast-build = inputs.nix-fast-build.packages.${system}.default;
  # nix-index-update = inputs.nix-alien.packages.${system}.nix-index-update;
  osu-lazer = unstable.osu-lazer;
  osu-lazer-bin = unstable.osu-lazer-bin;
  # prismlauncher = inputs.prismlauncher.packages.${system}.prismlauncher.override {
  #   jdks = [ final.temurin-bin ];
  # };
  proton-ge-bin = unstable.proton-ge-bin;
  xray = unstable.xray;
  # youtube-to-mpv = prev.callPackage ./packages/youtube-to-mpv.nix { term = config.defaultApplications.term.cmd; };
  # yt-archivist = prev.callPackage ./packages/yt-archivist { };
  yt-dlp = unstable.yt-dlp;
  sing-box = unstable.sing-box;
  wine = prev.wineWow64Packages.stagingFull;

  # Move modprobed config to subdir. Easier to use with impermanence
  modprobed-db = prev.modprobed-db.overrideAttrs (oa: {
    nativeBuildInputs = [ prev.makeWrapper ] ++ oa.nativeBuildInputs or [ ];
    postPatch =
      (oa.postPatch or "")
      + ''
        substituteInPlace ./common/modprobed-db.in \
          --replace-fail "/modprobed-db.conf" "/modprobed-db/modprobed-db.conf"
        substituteInPlace ./common/modprobed-db.skel \
          --replace-fail "/.config" "/.config/modprobed-db"
      '';
    postInstall =
      (oa.postInstall or "")
      + ''
        wrapProgram $out/bin/modprobed-db \
        --set PATH ${
          with final;
          lib.makeBinPath [
            gawk
            getent
            coreutils
            gnugrep
            gnused
            kmod
          ]
        }
      '';
  });

  pass-secret-service = prev.pass-secret-service.overrideAttrs (_: {
    installCheckPhase = null;
    postInstall = ''
      mkdir -p $out/share/{dbus-1/services,xdg-desktop-portal/portals}
      cat > $out/share/dbus-1/services/org.freedesktop.secrets.service << EOF
      [D-BUS Service]
      Name=org.freedesktop.secrets
      Exec=/run/current-system/sw/bin/systemctl --user start pass-secret-service
      EOF
      cp $out/share/dbus-1/services/{org.freedesktop.secrets.service,org.freedesktop.impl.portal.Secret.service}
      cat > $out/share/xdg-desktop-portal/portals/pass-secret-service.portal << EOF
      [portal]
      DBusName=org.freedesktop.secrets
      Interfaces=org.freedesktop.impl.portal.Secrets
      UseIn=gnome
      EOF
    '';
  });

  # narodmon-py = prev.writers.writePython3Bin "temp.py" {
  #   libraries = with prev.python3Packages; [ requests ];
  # } ./packages/narodmon-py.nix;

  # yandex-taxi-py = prev.writers.writePython3 "yandex-taxi.py" {
  #   libraries = with prev.python3Packages; [ requests ];
  # } ./packages/yandex-taxi-py.nix;
}
